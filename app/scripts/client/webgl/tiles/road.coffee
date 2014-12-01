Tile = require './tile.coffee'

class Road extends Tile
	type: 'road'

	setScale: ->
		@mesh.scale.set @tileSize.x, @tileSize.y, 0.25

module.exports = Road
