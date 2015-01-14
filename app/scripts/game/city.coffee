#
# City Controller
#

THREE = require 'three'
MapGenerator = require './map.coffee'
TileTypes = require './tiles/types.coffee'


class City

	population: 0

	constructor: (width=128, height=128, tileSize) ->
		@width = width
		@height = height
		@tileSize = tileSize
		@positionOffset = new THREE.Vector2(@width / 2, @height / 2)

		@terrain = new MapGenerator(@width * tileSize.x, @height * tileSize.y)
		@terrain.generate()

		@cityMap = []
		@roads = []
		@regions = []
		@typeGroups = {}

	getAbsoluteWidth: ->
		return @width * @tileSize.x

	getAbsoluteHeight: ->
		return @height * @tileSize.y

	_posForXY: (x, y) ->
		(y * @width) + x

	setTile: (type, x, y) ->
		tile = new TileTypes[type](x, y)
		@cityMap[@_posForXY(x, y)] = tile
		@addToGroup type, tile
		@updateNeighbors tile

	addToGroup: (type, tile) ->
		@typeGroups[type] = @typeGroups[type] || []
		@typeGroups[type].push tile

	updateNeighbors: (tile) ->
		north = @getTile(tile.x, tile.y - 1) if tile.y isnt 0
		south = @getTile(tile.x, tile.y + 1) if tile.y isnt @height - 1
		west = @getTile(tile.x - 1, tile.y) if tile.x isnt 0
		east = @getTile(tile.x + 1, tile.y) if tile.x isnt @width - 1

		if north
			north.neighbors.south = tile
			tile.neighbors.north = north
		if south
			south.neighbors.north = tile
			tile.neighbors.south = south
		if west
			west.neighbors.east = tile
			tile.neighbors.west = west
		if east
			east.neighbors.west = tile
			tile.neighbors.east = east

	getTile: (x, y) ->
		@cityMap[@_posForXY(x, y)]

	addTiles: (tiles) ->
		for tile in tiles
			position = tile.getMapPosition().add(@positionOffset)
			currentTile = @getTile(position.x, position.y)

			if currentTile isnt 'road'
				# console.log tile.type, position.x + @width / 2, position.y + @height /2, position.x, position.y
				@setTile(tile.type, position.x, position.y)

	action: (action, x, y) ->
		# Action is either 'build' or 'destroy'


module.exports = City
