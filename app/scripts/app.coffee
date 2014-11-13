'use strict'

webGLClient = require './client/webgl.coffee'
canvasClient = require './client/canvas.coffee'

class App
    constructor: ->
        @client = window.client = new webGLClient()
        # document.getElementById('canvas').appendChild @client.renderer.canvas
        document.body.appendChild @client.renderer.canvas

        return @

    start: ->
        console.log 'rendering'
        @client.render()

module.exports = App
