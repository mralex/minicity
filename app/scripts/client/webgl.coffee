THREE = require 'three'
OrbitControls = require '../lib/orbit_controls'
MapObject = require './webgl/map.coffee'
Stats = require '../lib/stats'

Renderer = require './webgl/renderer.coffee'
MouseHandler = require './webgl/mouse.coffee'

class Client
    constructor: ->
        @width = 1280
        @height = 720
        @renderer = new Renderer @width, @height
        @mouseHandler = new MouseHandler @renderer

        window.THREE = THREE

        console.log 'initializing map'
        @initializeMap()
        console.log 'done!'

        @initializeStats()

        @controls = new OrbitControls @renderer.camera, @renderer.canvas
        @controls.noRotate = true

    initializeStats: ->
        @stats = new Stats()
        @stats.setMode 0
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.left = '0px'
        @stats.domElement.style.top = '0px'
        @stats.domElement.style.zIndex = '1000'

        document.body.appendChild(@stats.domElement);

    initializeMap: ->
        @mapObject = new MapObject 256, 256
        @renderer.getScene().add @mapObject.map

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

    render: =>
        @stats.begin()

        @renderer.update()
        @mouseHandler.update([@mapObject.map])

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
