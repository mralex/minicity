
THREE = require 'three'
Map = require '../../game/map.coffee'

class CityMap
    types: {
        road: new THREE.Color 0x555555
        residential: new THREE.Color 0x00ff00
        industrial: new THREE.Color 0xffff00
        commercial: new THREE.Color 0x0000ff
        powerline: new THREE.Color 0xff5333
    }
    typeIndexes: {
        'road': 0
        'residential': 1
        'industrial': 2
        'commercial': 3
        'powerline': 4
    }

    constructor: (city, scale, client) ->
        @client = client
        @city = city
        @width = city.width
        @height = city.height
        @scale = scale

        @map = new THREE.Object3D
        @elements = []

        @initializeGeometry()

    initializeGeometry: ->
        @initializeMaterials()
        @cityMasterGeometry = new THREE.Geometry
        @cityMasterGeometry.dynamic = true


        @map = new THREE.Mesh @cityMasterGeometry, new THREE.MeshFaceMaterial(@materials)
        @addToMap 'residential', 0, 0, 0.5, 0.5

    initializeMaterials: ->
        @materials = [
            new THREE.MeshLambertMaterial { color: @types['road'] }
            new THREE.MeshLambertMaterial { color: @types['residential'] }
            new THREE.MeshLambertMaterial { color: @types['industrial'] }
            new THREE.MeshLambertMaterial { color: @types['commercial'] }
            new THREE.MeshLambertMaterial { color: @types['powerline'] }
        ]

    addToMap: (type, x, y, w, h) ->
        geometry = new THREE.PlaneGeometry 1, 1, 5, 5
        mesh = new THREE.Mesh geometry, @materials[@typeIndexes[type]]
        mesh.scale.set w, h, 1
        mesh.position.set x, y, 0.1
        mesh.updateMatrix()
        mesh.type = type
        @elements.push mesh
        # console.time 'merging'
        @cityMasterGeometry.merge mesh.geometry, mesh.matrix, @typeIndexes[type]
        @cityMasterGeometry.groupsNeedUpdate = true
        # console.timeEnd 'merging'

        if @elements.length % 10 is 0
            console.log 're-merging (' + @elements.length + ')'
            console.time 're-merging'
            @remerge()
            console.timeEnd 're-merging'

    remerge: ->
        geometry = new THREE.Geometry
        geometry.dynamic = true

        map = new THREE.Mesh geometry, new THREE.MeshFaceMaterial(@materials)
        for mesh in @elements
            geometry.merge mesh.geometry, mesh.matrix, @typeIndexes[mesh.type]

        map


module.exports = CityMap
