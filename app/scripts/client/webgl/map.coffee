
THREE = require 'three'
Map = require '../../game/map.coffee'

class MapObject
    types: {
        water: new THREE.Color 0x003fff
        tideWater: new THREE.Color 0x1111aa
        sand: new THREE.Color 0xf2e077
        grass: new THREE.Color 0x4bdb33
        hills: new THREE.Color 0x228b22
    }

    constructor: (city) ->
        @city = city
        @width = city.width
        @height = city.height

        @map = new THREE.Object3D

        @initializeGeometry()

    initializeGeometry: ->
        geometry = new THREE.PlaneGeometry 1, 1, 20, 20
        material = new THREE.MeshLambertMaterial {
            color: 0xffffff
            map: @generateTexture()
        }
        @map = new THREE.Mesh geometry, material
        @map.scale.set @width, @height, 1

    generateTexture: ->
        canvas = document.createElement 'canvas'
        ctx = canvas.getContext '2d'

        canvas.width = @width
        canvas.height = @height
        ctx.clearRect 0, 0, @width, @height

        imagedata = ctx.getImageData 0, 0, @width, @height
        data = imagedata.data

        for y in [0...@height]
            for x in [0...@width]
                value = @city.terrain.tileAt x, y
                i = (y * @width * 4) + x * 4
                color = null

                if value < 0
                    color = @types.water
                else if value > 0 and value < 0.008
                    color = @types.tideWater
                # Sand
                else if value > 0.008 and value < 0.0161
                    color = @types.sand
                # Grass
                else if value > 0.0161 and value < 0.2
                    color = @types.grass
                # Tundra
                else
                    color = @types.hills

                if color
                    data[i] = Math.round color.r * 255
                    data[i + 1] = Math.round color.g * 255
                    data[i + 2] = Math.round color.b * 255
                    data[i + 3] = 255

        ctx.putImageData imagedata, 0, 0

        @texture = new THREE.Texture canvas
        @texture.magFilter = THREE.NearestFilter
        @texture.minFilter = THREE.NearestFilter
        @texture.needsUpdate = true

        return @texture

module.exports = MapObject