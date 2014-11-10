THREE = require 'three'
OrbitControls = require '../lib/orbit_controls'
Map = require '../game/map.coffee'
Stats = require '../lib/stats'

class Client
    constructor: ->
        @width = 1920
        @height = 1080

        window.THREE = THREE

        @scene = new THREE.Scene
        @camera = new THREE.PerspectiveCamera 75, @width/@height, 0.1, 1000

        @camera.position.set(0, 0, 100)
        # @camera.rotation.order = 'YXZ'
        # @camera.rotation.y = - Math.PI / 4
        # @camera.rotation.x = Math.atan(-1 / Math.sqrt(2))

        @renderer = new THREE.WebGLRenderer

        @renderer.setSize @width, @height
        @renderer.setClearColor 0xffffff

        @canvas = @renderer.domElement

        console.log 'initializing map'
        @initializeMap()
        console.log 'done!'

        console.log 'adding lights'
        @light = new THREE.PointLight(0xffffff, 1.1, 0)
        @light.position.set(0.0, 0, 50)
        @scene.add @light

        @camera.rotation.set(0, 0, 0)

        @initializeStats()

        @controls = new OrbitControls @camera, @renderer.domElement
        @controls.noZoom = true

    initializeStats: ->
        @stats = new Stats()
        @stats.setMode 0
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.left = '0px'
        @stats.domElement.style.top = '0px'
        @stats.domElement.style.zIndex = '1000'

        document.body.appendChild(@stats.domElement);

    initializeMap: ->
        width = 128
        height = 128
        tileSize = 1
        
        @mapObject = new THREE.Object3D

        @map = new Map width, height
        @map.generate()
        geometry = new THREE.BoxGeometry tileSize, tileSize, tileSize
        mGeometry = new THREE.Geometry

        for y in [0...height]
            for x in [0...width]
                value = @map.tileAt x, y

                if value < 0
                    color = 0x0000ff
                # Sand
                else if value > 0 and value < 0.0133
                    color = 0xffff00
                # Grass
                else if value > 0.0133 and value < 0.2
                    color = 0x00ff00
                # Tundra
                else
                    color = 0x008800

                material = new THREE.MeshLambertMaterial { 
                    color: color
                    # emissive: 0xdddddd
                }
                mesh = new THREE.Mesh(geometry, material)
                mesh.position.set(x - (width / 2), y - (height / 2), value * 30)
                mesh.updateMatrix()

                mGeometry.merge(mesh.geometry, mesh.matrix)

        
        @mapObject = new THREE.Mesh(mGeometry, new THREE.MeshNormalMaterial())
        @scene.add @mapObject


    render: =>
        @stats.begin()
        # @mapObject.rotation.x += 0.01
        # @mapObject.rotation.y += 0.1
        @renderer.render @scene, @camera
        @stats.end()
        window.requestAnimationFrame @render

module.exports = Client
