
class ActionManager
	actions:
		'pointer': null
		'road': 'build'
		'residential': 'build'
		'commercial': 'build'
		'industrial': 'build'
		'powerstation': 'build'
		'powerline': 'build'
		'bulldoze': 'destroy'

	active:
		'pointer'

	getActive: ->
		@active

	setActive: (action) ->
		@active = action

module.exports = ActionManager

