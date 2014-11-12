THREE = require 'three'
OrbitControls = require '../lib/orbit_controls'
Map = require '../game/map.coffee'
Stats = require '../lib/stats'

class Client
    constructor: ->
        @width = 1280
        @height = 720

        window.THREE = THREE

        @scene = new THREE.Scene
        @camera = new THREE.PerspectiveCamera 75, @width/@height, 0.1, 1000

        @camera.position.set(0, 0, 100)
        # @camera.rotation.order = 'YXZ'
        # @camera.rotation.y = - Math.PI / 4
        # @camera.rotation.x = Math.atan(-1 / Math.sqrt(2))

        @renderer = new THREE.WebGLRenderer {
            alpha: true
        }

        @renderer.setSize @width, @height
        @renderer.setClearColor 0xffffff

        @canvas = @renderer.domElement

        console.log 'initializing map'
        @initializeMap()
        console.log 'done!'

        console.log 'adding lights'
        @light = new THREE.PointLight(0xffffff, 1.1, 0)
        @light.position.set(0.0, 0, 200)
        @scene.add @light

        @camera.rotation.set(0, 0, 0)

        @initializeStats()

        @controls = new OrbitControls @camera, @renderer.domElement
        @controls.noRotate = true

        @raycaster = new THREE.Raycaster
        @projector = new THREE.Projector
        @intersection
        @vector = new THREE.Vector3
        @mouse = {
            x: Infinity
            y: Infinity
        }

        @renderer.domElement.addEventListener 'mousemove', @handleMouseMove, false
        @renderer.domElement.addEventListener 'mouseover', @handleMouseOver, false
        @renderer.domElement.addEventListener 'mouseout', @handleMouseOut, false

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

        mWater = new THREE.MeshLambertMaterial({ color: 0x003fff })
        mTideWater = new THREE.MeshLambertMaterial({ color: 0x1111aa })
        mSand = new THREE.MeshLambertMaterial({ color: 0xf2e077 })
        mGrass = new THREE.MeshLambertMaterial({ color: 0x4dbd33 })
        mHills = new THREE.MeshLambertMaterial({ color: 0x228b22 })
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
                else if value > 0.008 and value < 0.0161
                    materialIndex = 2
                # Grass
                else if value > 0.0161 and value < 0.2
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
        @mapObject = new THREE.Mesh(geometry, materials)

        @scene.add @mapObject

    handleMouseMove: (e) =>
        e.preventDefault()

        left = @renderer.domElement.offsetLeft
        top = @renderer.domElement.offsetTop
        width = @renderer.domElement.offsetWidth
        height = @renderer.domElement.offsetHeight

        @mouse.x = ((e.clientX - left) / width) * 2 - 1
        @mouse.y = -((e.clientY - top) / height) * 2 + 1

    handleMouseOver: (e) =>
        @mouseOver = true

    handleMouseOut: (e) =>
        @mouseOver = false

    showCursor: (point) ->
        if not @cursor
            console.log 'foo'
            geometry = new THREE.PlaneGeometry 1, 1, 1
            material = new THREE.MeshBasicMaterial {
                color: 0x333333
                transparent: true
                opacity: 0.6
                visible: false
            }
            @cursor = new THREE.Mesh geometry, material
            @cursor.scale.set 2, 2, 1
            @cursor.position.set 0, 0, 0
            @scene.add @cursor

        # Snap to nearest grid 
        gridCellWidth = 2
        gridCellHeight = 2
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

        if @mouseOver
            vector = new THREE.Vector3(@mouse.x, @mouse.y, 1)
            @projector.unprojectVector vector, @camera
            @raycaster.ray.set(@camera.position, vector.sub(@camera.position).normalize())

            intersections = @raycaster.intersectObjects [@mapObject]
            intersection = if intersections.length > 0 then intersections[0] else null

            if intersection
                @intersection = intersection
                @showCursor(@intersection.point)
            else
                @removeCursor()
        else
            @removeCursor()

        @renderer.render @scene, @camera
        @stats.end()

        window.requestAnimationFrame @render

module.exports = Client
