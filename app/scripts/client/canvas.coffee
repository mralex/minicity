# Canvas test client
# For Perlin testing I guess

Perlin = require '../lib/perlin.coffee'
Map = require '../game/map.coffee'

class Client
    constructor: ->
        @width = 1280
        @height = 720
        @perlin = new Perlin()
        @map = new Map(@width, @height)
        @canvas = document.createElement 'canvas'
        @canvas.width = @width
        @canvas.height = @height
        @ctx = @canvas.getContext '2d'

        image = @ctx.createImageData @canvas.width, @canvas.height
        data = image.data
        window.data = image.data

        tiles = @map.generate()
        window.tiles = tiles

        for y in [0...@height]
            for x in [0...@width]
                cell = (y * @width * 4) + x * 4
                value = @map.tileAt(x, y)

                if value < 0
                    data[cell] = 0
                    data[cell + 1] = 0
                    data[cell + 2] = 255
                else if value > 0 and value < 0.0125
                    data[cell] = 255
                    data[cell + 1] = 255
                    data[cell + 2] = 0
                else if value > 0.0125 and value < 0.2
                    data[cell] = 0
                    data[cell + 1] = 255
                    data[cell + 2] = 0
                else if value > 0.2 and value < 0.4
                    data[cell] = 0
                    data[cell + 1] = 128
                    data[cell + 2] = 0
                else
                    data[cell] = data[cell + 1] = data[cell + 2] = 255

                # data[cell] = data[cell + 1] = data[cell + 2] =  Math.abs value * 255

                data[cell + 3] = 255

        @ctx.putImageData image, 0, 0

        return @

    render: ->
        return

module.exports = Client
