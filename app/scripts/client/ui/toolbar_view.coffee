Backbone = require '../../lib/backbone.coffee'

class ToolbarView extends Backbone.View
	className: 'js-toolbar'
	events:
		'click .js-tool': 'changeTool'
		'click .js-action': 'triggerInteraction'

	initialize: (options) ->
		@currentAction = options.action

	changeTool: (e) =>
		e.preventDefault()

		@$('a').removeClass 'selected'
		@$(e.currentTarget).addClass 'selected'

		action = @$(e.currentTarget).data 'action'

		if action isnt @currentAction
			@currentAction = action 
			@trigger 'action-changed', @currentAction

	triggerInteraction: (e) =>
		e.preventDefault()

		action = @$(e.currentTarget).data 'action'
		@trigger 'interaction', action

	render: ->


module.exports = ToolbarView
