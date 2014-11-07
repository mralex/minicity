'use strict'

THREE = require 'three'

App = ->
  console.log 'app initialized'

App.prototype.beep = ->
  console.log 'coffee hi!'

module.exports = App
