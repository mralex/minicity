
class Chunk
	constructor: (width=16, height=16) ->
		@width = width
		@height = height

		@entities = {}

		@_isDirty = false

module.exports = Chunk
