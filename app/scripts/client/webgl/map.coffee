
THREE = require 'three'
Map = require '../../game/map.coffee'

class MapObject
    constructor: (width, height) ->
        @width = width
        @height = height

        @map = new THREE.Object3D

        @mapData = new Map @width, @height
        @mapData.generate()

        @initializeGeometry()

    initializeGeometry: ->
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

        geometry = new THREE.PlaneGeometry(@width, @height, @width,@height)

        for y in [0...@height]
            for x in [0...@width]
                value = @mapData.tileAt x, y
                # faceIndex = (y * width * 2) + x * 2
                faceIndex = (x * @height * 2) + y * 2
                face = geometry.faces[faceIndex]
                face2 = geometry.faces[faceIndex + 1]

                vertexIndex = (y * @width) + x

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
        @map = new THREE.Mesh(geometry, materials)

module.exports = MapObject
