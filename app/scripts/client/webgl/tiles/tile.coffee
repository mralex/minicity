THREE = require 'three'
materialsConstants = require '../materials.coffee'

class Tile
	type: 'road'

	constructor: (position) ->
		@chunk = null
		@position = position
		@tileSize = new THREE.Vector2(8, 8) # XXX Make this a constant somewhere

		@generateGeometry()

	getMapPosition: ->
		unless @_mapPosition
			@_mapPosition = new THREE.Vector2(
				Math.floor(@position.x / @tileSize.x),
				Math.floor(@position.y / @tileSize.y)
			)
		return @_mapPosition

	update: ->

	generateGeometry: ->
		@geometry = new THREE.BoxGeometry 1, 1, 1

		for i in [0...@geometry.faces.length]
			@geometry.faces[i].materialIndex = materialsConstants.typeIndexes[@type]

		@geometry.applyMatrix(new THREE.Matrix4().makeTranslation(0, 0, 0.5))
		@geometry.verticesNeedUpdate = true

		@mesh = new THREE.Mesh @geometry
		@mesh.position.set @position.x, @position.y, 0
		@setScale()
		@mesh.updateMatrix()

	setScale: ->
		@mesh.scale.set @tileSize.x, @tileSize.y, Math.floor(Math.random() * 5 + 5)

	getMesh: ->
		@mesh

module.exports = Tile
