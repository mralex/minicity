THREE = require 'three'
Chunk = require './chunk.coffee'

class World
	constructor: (width=128, height=128) ->
		@chunkWidth = 16
		@chunkHeight = 16

		@width = width
		@heigh = height

		@xChunks = Math.floor(width / @chunkWidth)
		@yChunks = Math.floor(height / @chunkHeight)

		@chunks = {}

	chunkForWorldPosition: (position) ->
		x = Math.floor(position.x / @chunkWidth)
		y = Math.floor(position.y / @chunkHeight)

		new THREE.Vector2(x, y)

	worldPositionInChunk: (position) ->
		x = position.x % @chunkWidth
		y = position.y % @chunkHeight

		new THREE.Vector2(x, y)

module.exports = World
