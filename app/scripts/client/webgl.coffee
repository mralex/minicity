_ = require 'underscore'
THREE = require 'three'
OrbitControls = require '../lib/orbit_controls'
MapObject = require './webgl/map.coffee'
Stats = require '../lib/stats'

City = require '../game/city.coffee'

Renderer = require './webgl/renderer.coffee'
MouseHandler = require './webgl/mouse.coffee'


class Client
    constructor: ->
        @width = 1280
        @height = 720
        @renderer = new Renderer @width, @height
        @mouseHandler = new MouseHandler @renderer

        window.THREE = THREE

        console.log 'initializing city'
        @initializeCity()
        console.log 'done!'

        @initializeStats()

        @controls = new OrbitControls @renderer.camera, @renderer.canvas
        @controls.noRotate = true

        @mouseHandler.on 'mousedown', @handleMouseDown
        @mouseHandler.on 'mouseup', @handleMouseUp
        @mouseHandler.on 'mousemove', @handleMouseMove

    initializeStats: ->
        @stats = new Stats()
        @stats.setMode 0
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.left = '0px'
        @stats.domElement.style.top = '0px'
        @stats.domElement.style.zIndex = '1000'

        document.body.appendChild(@stats.domElement);

    initializeCity: ->
        @city = new City 512, 512
        @terrainObject = new MapObject @city
        @renderer.getScene().add @terrainObject.map

    showCursor: (point) ->
        gridCellWidth = 2
        gridCellHeight = 2

        if not @cursor
            geometry = new THREE.PlaneGeometry 1, 1, 1
            material = new THREE.MeshBasicMaterial {
                color: 0x333333
                transparent: true
                opacity: 0.4
                visible: false
            }
            @cursor = new THREE.Mesh geometry, material
            @cursor.scale.set gridCellWidth, gridCellHeight, 1
            @cursor.position.set 0, 0, 0
            @renderer.getScene().add @cursor

        # Snap to nearest grid 
        point.x = (Math.floor(point.x / gridCellWidth) * gridCellWidth) + 1
        point.y = (Math.floor(point.y / gridCellHeight) * gridCellHeight) + 1

        @cursor.position.set point.x, point.y, 0
        @cursor.material.visible = true
        @cursor.material.needsUpdate

    removeCursor: ->
        if @cursor
            @cursor.material.visible = false
            @cursor.material.needsUpdate

    handleMouseDown: (mousePosition, position) =>
        @mouseDown = true

        if position
            @absoluteStartPosition = _.clone position

    handleMouseUp: (mousePosition, position) =>
        @mouseDown = false

        if @selection
            @selection.material.visible = false
            @selection.material.needsUpdate

    handleMouseMove: (mousePosition, position) =>
        if not @mouseDown or not position
            return

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
        gridCellWidth = 2
        gridCellHeight = 2
        start.x = (Math.floor(start.x / gridCellWidth) * gridCellWidth)
        start.y = (Math.floor(start.y / gridCellHeight) * gridCellHeight)
        end.x = (Math.floor(end.x / gridCellWidth) * gridCellWidth)
        end.y = (Math.floor(end.y / gridCellHeight) * gridCellHeight)

        width = Math.abs(end.x - start.x) or gridCellWidth
        height = Math.abs(end.y - start.y) or gridCellHeight

        cx = width / 2 + start.x
        cy = height / 2 + start.y

        @selection.scale.set width, height, 1
        @selection.position.set cx, cy, 0

        @selection.material.visible = true
        @selection.material.needsUpdate

    render: =>
        @stats.begin()

        @renderer.update()
        @mouseHandler.update([@terrainObject.map])

        if @mouseHandler.mouseOver
            if @mouseHandler.intersection
                @showCursor(@mouseHandler.intersection.point)
            else
                @removeCursor()
        else
            @removeCursor()

        
        @renderer.render()
        @stats.end()

        window.requestAnimationFrame @render

module.exports = Client
