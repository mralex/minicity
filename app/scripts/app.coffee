'use strict'

webGLClient = require './client/webgl.coffee'
canvasClient = require './client/canvas.coffee'

class App
    constructor: ->
        @client = new canvasClient()
        document.body.appendChild @client.canvas

        return @

    start: ->
        @client.render()

    beep: ->
        console.log 'coffee hi!'

module.exports = App
