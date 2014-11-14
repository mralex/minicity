#
# City Controller
#

MapGenerator = require './map.coffee'

class City

	population: 0

	constructor: (width=128, height=128) ->
		@width = width
		@height = height

		@terrain = new MapGenerator(@width, @height)
		@terrain.generate()

		@cityMap = new Array @width, @height

	_posForXY: (x, y) ->
		(y * @width) + x

	setTile: (tile, x, y) ->
		@map[@_posForXY(x, y)] = tile

	getTile: (x, y) ->
		@map[@_posForXY(x, y)]

module.exports = City
