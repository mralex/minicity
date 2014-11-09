#
# Map Generator
# 

Perlin = require '../lib/perlin.coffee'
MapTypes = require './map_types.coffee'

class Map
    constructor: (width, height) ->
        @width = width
        @height = height
        @map = []
        @perlin = new Perlin()

    generate: ->
        for y in [0...@height]
            for x in [0...@width]
                nx = x / @width
                ny = y / @height
                size = 0.85

                @map.push @perlin.perlin2(nx * size, ny * size, 2, 0.25, 2.53)

        @map

    tileAt: (x, y) ->
        @map[(y * @width) + x]

module.exports = Map
