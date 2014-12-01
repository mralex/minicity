THREE = require 'three'
Chunk = require './chunk.coffee'
materialConstants = require './materials.coffee'
TileTypes = require './tiles/tiles.coffee'


class World
	constructor: (width=128, height=128, scene) ->
		@chunkSize = new THREE.Vector2(16, 16)
		@worldSize = new THREE.Vector2(width, height)
		@tileSize = new THREE.Vector2(8, 8)

		@scene = scene

		@xChunks = Math.floor(@worldSize.x / @chunkSize.x)
		@yChunks = Math.floor(@worldSize.y / @chunkSize.y)

		@chunks = {}

	_chunkPositionForWorldPosition: (position) ->
		x = Math.floor((position.x / @tileSize.x) / @chunkSize.x)
		y = Math.floor((position.y / @tileSize.y) / @chunkSize.y)

		new THREE.Vector2(x, y)

	_worldPositionInChunk: (position) ->
		x = Math.floor((position.x / @tileSize.x) % @chunkSize.x)
		y = Math.floor((position.y / @tileSize.y) % @chunkSize.y)

		new THREE.Vector2(x, y)

	_getChunk: (position) ->
		chunkPosition = @_chunkPositionForWorldPosition(position)
		key = chunkPosition.x + ',' + chunkPosition.y

		if key not of @chunks
			@chunks[key] = new Chunk(@chunkSize, chunkPosition, @)

		@chunks[key]

	_deleteChunk: (position) ->
		chunkPosition = @_chunkPositionForWorldPosition(position)
		key = chunkPosition.x + ',' + chunkPosition.y

		if key of @chunks
			@chunks[key].destroy()
			delete @chunks[key]

	_commitChunks: ->
		for key, chunk of @chunks
			chunk.commit()

	add: (tile, worldPosition, commit=true) ->
		chunk = @_getChunk(worldPosition)
		chunkPosition = @_worldPositionInChunk(worldPosition)

		chunk.add(tile, chunkPosition, commit)

	remove: (tile, worldPosition) ->
		chunk = @_getChunk(worldPosition)
		chunkPosition = @_worldPositionInChunk(worldPosition)

		chunk.remove(tile, chunkPosition)

		if chunk.isEmpty()
			@_deleteChunk(worldPosition)

	addTiles: (type, x, y, w, h) ->
		# Break into tile sized pieces and add to world
		xCount = w / @tileSize.x
		yCount = h / @tileSize.y

		origin = new THREE.Vector2(
			x - w / 2 + @tileSize.x / 2,
			y - h / 2 + @tileSize.y / 2
		)

		for _y in [0...yCount]
			for _x in [0...xCount]
				position = new THREE.Vector2(
					origin.x + (@tileSize.x * _x),
					origin.y + (@tileSize.y * _y)
				)

				# geometry = new THREE.PlaneGeometry 1, 1
				# mesh = new THREE.Mesh geometry, materialConstants.materials[materialConstants.typeIndexes[type]]
				# mesh.scale.set @tileSize.x, @tileSize.y, 1
				# mesh.position.set position.x, position.y, 0.1
				# mesh.updateMatrix()
				# mesh.type = type
				tile = new TileTypes[type](position)
				tile.type = type

				@add(tile, position, false)

		@_commitChunks()

	update: (time) ->
		for own key, chunk of @chunks
			chunk.update(time)

module.exports = World
