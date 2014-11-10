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
        @light.position.set(0.0, 0, 100)
        @scene.add @light

        @camera.rotation.set(0, 0, 0)

        @initializeStats()

        @controls = new OrbitControls @camera, @renderer.domElement
        # @controls.noZoom = true

    initializeStats: ->
        @stats = new Stats()
        @stats.setMode 0
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.left = '0px'
        @stats.domElement.style.top = '0px'
        @stats.domElement.style.zIndex = '1000'

        document.body.appendChild(@stats.domElement);

    initializeMap: ->
        width = 256
        height = 256
        tileSize = 1
        
        @mapObject = new THREE.Object3D

        @map = new Map width, height
        @map.generate()

        mWater = new THREE.MeshLambertMaterial({ color: 0x0000ff })
        mTideWater = new THREE.MeshLambertMaterial({ color: 0x1111aa })
        mSand = new THREE.MeshLambertMaterial({ color: 0xffff00 })
        mGrass = new THREE.MeshLambertMaterial({ color: 0x00ff00 })
        mHills = new THREE.MeshLambertMaterial({ color: 0x008800 })
        materials = new THREE.MeshFaceMaterial([
            mWater
            mTideWater
            mSand
            mGrass
            mHills
        ])

        geometry = new THREE.PlaneGeometry(width, height, width, height)

        for y in [0...height]
            for x in [0...width]
                value = @map.tileAt x, y
                # faceIndex = (y * width * 2) + x * 2
                faceIndex = (x * height * 2) + y * 2
                face = geometry.faces[faceIndex]
                face2 = geometry.faces[faceIndex + 1]

                vertexIndex = (y * width) + x

                if value < 0
                    materialIndex = 0
                else if value > 0 and value < 0.008
                    materialIndex = 1
                # Sand
                else if value > 0.008 and value < 0.0159
                    materialIndex = 2
                # Grass
                else if value > 0.0159 and value < 0.2
                    materialIndex = 3
                # Tundra
                else
                    materialIndex = 4

                face.materialIndex = face2.materialIndex = materialIndex

                # if geometry.vertices[vertexIndex]
                #     geometry.vertices[vertexIndex].z = value * 30
                # if geometry.vertices[vertexIndex + 1]
                #     geometry.vertices[vertexIndex + 1].z = value * 30
                # if geometry.vertices[vertexIndex + 2]
                #     geometry.vertices[vertexIndex + 2].z = value * 30
                # geometry.vertices[vertexIndex + 3] = value * 10
                # geometry.vertices[vertexIndex + 4] = value * 10
                # geometry.vertices[vertexIndex + 5] = value * 10

        geometry.facesNeedUpdate
        geometry.verticesNeedUpdate
        # @mapObject = new THREE.Mesh(geometry, new THREE.MeshNormalMaterial({ wireframe: true }))
        @mapObject = new THREE.Mesh(geometry, materials)

        @scene.add @mapObject


    render: =>
        @stats.begin()
        # @mapObject.rotation.x += 0.01
        # @mapObject.rotation.y += 0.1
        @renderer.render @scene, @camera
        @stats.end()
        window.requestAnimationFrame @render

module.exports = Client
