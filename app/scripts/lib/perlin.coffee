#
# Generate multiple octave perlin noise
# CoffeeScript implementation of https://github.com/caseman/ism/blob/master/lib/fbmnoise.js
#

Noise = require 'noisejs'

class Perlin
    constructor: ->
        @seed = Math.random()
        console.log 'Map seed: ' + @seed
        @noise = new Noise @seed

    perlin2: (x, y, octaves=1, persistence=0.5, lacunarity=2) ->
        freq = 1.0
        amp = 1.0
        max = 0
        val = 0

        for i in [0..octaves]
            val += @noise.perlin2(x * freq, y * freq) * amp
            max += amp
            freq *= lacunarity
            amp *= persistence

        val / max

module.exports = Perlin
