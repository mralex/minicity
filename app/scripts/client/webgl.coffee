$ = require 'jquery'
_ = require 'underscore'
THREE = require 'three'
TrackballControls = require '../lib/orbit_controls'
TerrainMap = require './webgl/terrain_map.coffee'
CityMap = require './webgl/city_map.coffee'
Stats = require '../lib/stats'

ToolbarView = require './ui/toolbar_view.coffee'

City = require '../game/city.coffee'

Renderer = require './webgl/renderer.coffee'
MouseHandler = require './webgl/mouse.coffee'


class Client
    gridCellWidth: 8
    gridCellHeight: 8
    mapScale: 2
    mapWidth: 512
    mapHeight: 512

    constructor: ->
        @toolbar = new ToolbarView { action: 'pointer', el: $('.js-toolbar') }
        @toolbar.render()

        @renderer = new Renderer
        @mouseHandler = new MouseHandler @renderer

        window.THREE = THREE

        console.log 'initializing city'
        @initializeCity()
        console.log 'done!'

        @initializeStats()

        @controls = new TrackballControls @renderer.camera, @renderer.canvas
        @controls.noRotate = true

        @mouseHandler.on 'mousedown', @handleMouseDown
        @mouseHandler.on 'mouseup', @handleMouseUp
        @mouseHandler.on 'mousemove', @handleMouseMove

        @action = 'pointer'
        @toolbar.on 'action-changed', (action) =>
            @action = action
            console.log action

    initializeStats: ->
        @stats = new Stats()
        @stats.setMode 0
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.left = '0px'
        @stats.domElement.style.top = '0px'
        @stats.domElement.style.zIndex = '1000'

        document.body.appendChild(@stats.domElement);

    initializeCity: ->
        @city = new City @mapWidth, @mapHeight
        @terrainMap = new TerrainMap @city, @mapScale
        @cityMap = new CityMap @city, @mapScale, @

        @renderer.getScene().add @terrainMap.map
        @renderer.getScene().add @cityMap.map

    showCursor: (point) ->
        if not @cursor
            geometry = new THREE.PlaneGeometry 1, 1, 1
            material = new THREE.MeshBasicMaterial {
                color: 0x333333
                transparent: true
                opacity: 0.4
                visible: false
            }
            @cursor = new THREE.Mesh geometry, material
            @cursor.scale.set @gridCellWidth, @gridCellHeight, 1
            @cursor.position.set 0, 0, 0.5
            @renderer.getScene().add @cursor

        # matrix = new THREE.Matrix4
        # matrix.makeScale Math.sqrt(2) / 2, Math.sqrt(2) / 4, 1
        # matrix.makeRotationZ -(0.0174532925 * 45)

        # point.applyMatrix4 matrix

        # Snap to nearest grid 
        point.x = (Math.floor(point.x / @gridCellWidth) * @gridCellWidth) + (@gridCellWidth / 2)
        point.y = (Math.floor(point.y / @gridCellHeight) * @gridCellHeight) + (@gridCellWidth / 2)

        @cursor.position.set point.x, point.y, 0.1
        @cursor.material.visible = true
        @cursor.material.needsUpdate

    hideCursor: ->
        if @cursor
            @cursor.material.visible = false
            @cursor.material.needsUpdate

    handleMouseDown: (mousePosition, position) =>
        @mouseDown = true
        @hasSelection = false

        if position
            @absoluteStartPosition = _.clone position

    handleMouseUp: (mousePosition, position) =>
        @mouseDown = false

        if @selection and @hasSelection
            @selection.material.visible = false
            @selection.material.needsUpdate

            if @action isnt 'pointer'
                @cityMap.addToMap @action, @selection.position.x, @selection.position.y, @selection.scale.x, @selection.scale.y

    handleMouseMove: (mousePosition, position) =>
        if not @mouseDown or not position
            return

        @hasSelection = true
        @absolutePosition = _.clone position

        if not @selection
            geometry = new THREE.PlaneGeometry 1, 1
            material = new THREE.MeshBasicMaterial {
                color: 0x333333
                transparent: true
                opacity: 0.4
                visible: false
            }
            @selection = new THREE.Mesh geometry, material
            @renderer.getScene().add @selection

        start = new THREE.Vector2 Math.min(@absoluteStartPosition.x, @absolutePosition.x), Math.min(@absoluteStartPosition.y, @absolutePosition.y)
        end = new THREE.Vector2 Math.max(@absoluteStartPosition.x, @absolutePosition.x), Math.max(@absoluteStartPosition.y, @absolutePosition.y)

        # Snap to grid
        start.x = (Math.floor(start.x / @gridCellWidth) * @gridCellWidth)
        start.y = (Math.floor(start.y / @gridCellHeight) * @gridCellHeight)
        end.x = (Math.floor(end.x / @gridCellWidth) * @gridCellWidth)
        end.y = (Math.floor(end.y / @gridCellHeight) * @gridCellHeight)

        width = Math.abs(end.x - start.x) + @gridCellWidth
        height = Math.abs(end.y - start.y) + @gridCellHeight

        if @action in ['road', 'powerline']
            if width > height
                height = @gridCellHeight
            else
                width = @gridCellWidth

        cx = width / 2 + start.x
        cy = height / 2 + start.y

        @selection.scale.set width, height, 1
        @selection.position.set cx, cy, 0.1

        @selection.material.visible = true
        @selection.material.needsUpdate = true

    render: =>
        @stats.begin()

        @renderer.update()
        @mouseHandler.update([@terrainMap.map])

        if @mouseHandler.mouseOver and not @mouseDown
            if @mouseHandler.intersection
                @showCursor(@mouseHandler.intersection.point)
            else
                @hideCursor()
        else
            # @hideCursor()

        
        # @controls.update()
        @renderer.render()
        @stats.end()

        window.requestAnimationFrame @render

module.exports = Client
