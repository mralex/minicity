THREE = require 'three'
_ = require 'underscore'
materialConstants = require './materials.coffee'


class Chunk
	constructor: (size, position, world) ->
		@size = size
		@position = position
		@world = world

		@entities = {}
		@_pendingEntities = []

		@_isDirty = false

		# @showBounding()

	destroy: ->
		# Remove geometry from scene
		@_destroyGeometry()

	showBounding: ->
		geometry = new THREE.BoxGeometry 1, 1, 1
		material = new THREE.MeshBasicMaterial({
			color: 0x880000
			wireframe: true
		})
		mesh = new THREE.Mesh geometry, material
		mesh.scale.set 16 * 8, 16 * 8, 16 * 8
		mesh.position.set @position.x * 16 * 8 + 16 * 4, @position.y * 16 * 8 + 16 * 4, 8 * 8

		@world.scene.add mesh

	add: (tile, position, commit=true) ->
		key = @_keyForPosition(position)

		if key of @entities
			if @entities[key].type is 'road'
				return

			# XXX Make this a deferred, so we can animate out destroyed tiles
			# @entities[key].destroy()
			@_destroyGeometry()

		tile.chunk = @
		@entities[key] = tile
		@_pendingEntities.push key

		if commit
			@_generateGeometry()

	remove: (tile, position) ->
		key = @_keyForPosition(position)

		if key of @entities
			@entities[key].destroy()
			delete @entities[key]
			@_destroyGeometry()
			@_generateGeometry()

	commit: ->
		if @_pendingEntities.length
			@_generateGeometry()

	update: (time) ->
		# Update things in the chunk

	_keyForPosition: (position) ->
		position.x + ',' + position.y

	_destroyGeometry: ->
		@world.scene.remove @_chunkMesh if @_chunkMesh
		@_chunkMesh = undefined

	_generateGeometry: ->
		if _.isEmpty(@entities)
			return

		unless @_chunkMesh
			@_chunkGeometry = new THREE.Geometry
			@_chunkGeometry.dynamic = true

			for position,tile of @entities
				mesh = tile.getMesh()
				@_chunkGeometry.merge mesh.geometry, mesh.matrix, materialConstants.typeIndexes[tile.type]

			@_chunkMesh = new THREE.Mesh @_chunkGeometry, new THREE.MeshFaceMaterial(materialConstants.materials)

			@_pendingEntities = []

			@world.scene.add @_chunkMesh

		for position in @_pendingEntities
			mesh = @entities[position].getMesh()
			@_chunkGeometry.merge mesh.geometry,  mesh.matrix, materialConstants.typeIndexes[@entities[position].type]
			@_chunkGeometry.groupsNeedUpdate = true
		
		@_pendingEntities = []			


module.exports = Chunk
