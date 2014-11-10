#
# City Controller
#

MapGenerator = require 'map.coffee'

class City
	width: 128
	height: 128

	population: 0

	constructor: ->
		@map = (new MapGenerator(@width, @height)).generate()


module.exports = City
