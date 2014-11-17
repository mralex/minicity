
Tile = require './tile.coffee'

class Road extends Tile
	_type: 'road'
	width: 4
	height: 4

module.exports = Road
