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

    generate: (seed) ->
        @map = []
        @perlin = new Perlin(seed)
        for y in [0...@height]
            for x in [0...@width]
                nx = x / @width
                ny = y / @height
                size = 1.5

                @map.push @perlin.perlin2(nx * size, ny * size, 8, 0.25, 2.3) + 0.11

        @calculateLandMass()

        if @landMass < 0.4
            console.log 'Not enough land!'
            @generate()

        @seed = @perlin.seed

        @map

    calculateLandMass: ->
        land = 0
        water = 0
        sand = 0
        size = @map.length
        @landMass = 0
        @waterMass = 0

        for value in @map
            # Water
            if value < 0
                water++
            # Sand
            else if value > 0 and value < 0.0133
                land++
                sand++
            # Grass
            else
                land++

        @landMass = land / size
        @waterMass = water / size

        # console.log 'Land: ' + land + ', Beach: ' + sand + ', Water: ' + water
        console.log (@landMass * 100).toPrecision(4) + '% land, ' + (@waterMass * 100).toPrecision(4) + '% water'

    tileAt: (x, y) ->
        @map[(y * @width) + x]

module.exports = Map
