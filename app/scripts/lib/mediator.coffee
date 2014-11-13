#
# Mediatorjs
# https://github.com/parris/mediatorjs
#

Events = require 'backbone.events'

class Mediator

    attributes: {}

    constructor: () ->

    set: (key, data) ->
        @attributes[key] = data

    get: (key) ->
        @attributes[key]

Events.mixin Mediator.prototype

mediator = new Mediator
mediator.Mediator = Mediator

module.exports = mediator
