#
# City Controller
#

MapGenerator = require './map.coffee'
TileTypes = require './tiles/types.coffee'


class City

	population: 0

	constructor: (width=128, height=128, tileSize) ->
		@width = width
		@height = height
		@tileSize = tileSize

		@terrain = new MapGenerator(@width * tileSize.x, @height * tileSize.y)
		@terrain.generate()

		@cityMap = new Array @width * @height
		@roads = new Array @width * @height
		@regions = []

	getAbsoluteWidth: ->
		return @width * @tileSize.x

	getAbsoluteHeight: ->
		return @height * @tileSize.y

	_posForXY: (x, y) ->
		x += @width / 2
		y += @height / 2
		(y * @width) + x

	setTile: (type, x, y) ->
		tile = new TileTypes[type](x, y)
		@cityMap[@_posForXY(x, y)] = tile

	getTile: (x, y) ->
		@cityMap[@_posForXY(x, y)]

	addTiles: (tiles) ->
		for tile in tiles
			position = tile.getMapPosition()
			currentTile = @getTile(position.x, position.y)

			if currentTile isnt 'road'
				console.log tile.type, position.x + @width / 2, position.y + @height /2
				@setTile(tile.type, position.x, position.y)

	action: (action, x, y) ->
		# Action is either 'build' or 'destroy'


module.exports = City
