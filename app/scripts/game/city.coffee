#
# City Controller
#

THREE = require 'three'
_ = require 'underscore'
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
		@zones = {}
		@parcels = []

	getAbsoluteWidth: ->
		return @width * @tileSize.x

	getAbsoluteHeight: ->
		return @height * @tileSize.y

	_posForXY: (x, y) ->
		(y * @width) + x

	setTile: (type, x, y) ->
		tile = new TileTypes[type](x, y)
		@cityMap[@_posForXY(x, y)] = tile
		@updateNeighbors tile
		@addToZone tile
		tile

	addToZone: (tile) ->
		@zones[tile.type()] = @zones[tile.type()] || []
		@zones[tile.type()].push tile

	# Add parcel of tiles to list of parcels, or merge it with an
	# existing one if it borders one with the same zone type
	addToParcels: (parcel) ->
		ajoining = []
		overlapping = []
		last = _.last parcel.tiles

		for _parcel in @parcels
			continue if _parcel.type isnt parcel.type

			# Do we overlap?
			if (parcel.min.x < _parcel.max.x and parcel.min.y < _parcel.max.y and parcel.max.x > _parcel.min.x and parcel.max.y > _parcel.min.y)
				overlapping.push _parcel

			# Are we ajoining?
			if (@checkAjoin(parcel, _parcel))
				ajoining.push _parcel

		if ajoining.length
			# Merge ajoining parcels together
			console.log ajoining.length + ' ajoining parcels'

		if overlapping.length
			# Merge ajoining parcels together
			console.log overlapping.length + ' overlapping parcels'

		@parcels.push parcel

	checkAjoin: (parcelA, parcelB) ->
		# Check top: minY - 1, between minX : maxX
		if (parcelA.min.y is parcelB.max.y and parcelA.max.x >= parcelB.min.x and parcelA.min.x <= parcelB.max.x)
			return true

		# Check bottom: maxY, between minX : maxX
		if (parcelA.max.y is parcelB.min.y and parcelA.max.x >= parcelB.min.x and parcelA.min.x <= parcelB.max.x)
			return true

		# Check left: minX - 1, between minY : maxY
		if (parcelA.min.x is parcelB.max.x and parcelA.max.y >= parcelB.min.y and parcelA.min.y <= parcelB.max.y)
			return true

		# Check right: maxX, between minY : maxY
		if (parcelA.max.x is parcelB.min.x and parcelA.max.y >= parcelB.min.y and parcelA.min.y <= parcelB.max.y)
			return true

		return false

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

	scoreRoadProximity: (parcel) ->
		# Get edge tiles
		edges = []
		width = parcel.size.x
		height = parcel.size.y
		for y in [0...height]
			if y is 0 or y is height - 1
				# Get all tiles [0, y] to [width,y]
				edges = edges.concat(parcel.tiles[y * width...y * width + width])
			else
				# Get tiles at [0, y] and [width, y]
				edges.push parcel.tiles[y * width]
				edges.push parcel.tiles[y * width + (width - 1)]

		# Check if edge tiles are next to a road
		roads = edges.map((edge) -> edge.isNextToRoad() if edge)

		# Score tiles accordingly
		for edge, i in edges
			if roads[i]
				# XXX Maybe multiply by the number of adjacent roads?
				edge.roadScore = 5

	getTile: (x, y) ->
		@cityMap[@_posForXY(x, y)]

	addTiles: (tiles) ->
		parcel = {
			type: ''
			tiles: []
		}

		for tile in tiles
			position = tile.getMapPosition().add(@positionOffset)
			currentTile = @getTile(position.x, position.y)

			unless currentTile and currentTile.type() is 'road' or currentTile and currentTile.type() is tile.type
				console.log currentTile
				# console.log tile.type, position.x + @width / 2, position.y + @height /2, position.x, position.y
				parcel.tiles.push @setTile(tile.type, position.x, position.y)

		if parcel.tiles.length
			last = _.last parcel.tiles

			parcel.type = parcel.tiles[0].type()
			parcel.min = new THREE.Vector2(parcel.tiles[0].x, parcel.tiles[0].y)
			parcel.max = new THREE.Vector2(last.x, last.y).addScalar(1)
			parcel.size = parcel.max.clone().sub(parcel.min)
			console.time 'parceling'
			# @addToParcels parcel
			if parcel.type is 'road'
				console.log 'One day I\'ll score nearby zoned tiles'
			else
				@scoreRoadProximity parcel

			console.timeEnd 'parceling'

	action: (action, x, y) ->
		# Action is either 'build' or 'destroy'


module.exports = City
