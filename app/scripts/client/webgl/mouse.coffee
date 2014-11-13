
THREE = require 'three'
Events = require 'backbone.events'
_ = require 'underscore'


class MouseHandler
    _(@::).extend Events

    constructor: (renderer) ->
        @renderer = renderer
        @raycaster = new THREE.Raycaster
        @projector = new THREE.Projector

        @intersection = null

        @mouse = {
            x: Infinity
            y: Infinity
        }

        @renderer.canvas.addEventListener 'mousemove', @handleMouseMove, false
        @renderer.canvas.addEventListener 'mouseover', @handleMouseOver, false
        @renderer.canvas.addEventListener 'mouseout', @handleMouseOut, false
        @renderer.canvas.addEventListener 'mouseup', @handleMouseUp, false
        @renderer.canvas.addEventListener 'mousedown', @handleMouseDown, false

    handleMouseMove: (e) =>
        e.preventDefault()

        left = @renderer.canvas.offsetLeft
        top = @renderer.canvas.offsetTop
        width = @renderer.canvas.offsetWidth
        height = @renderer.canvas.offsetHeight

        @mouse.x = ((e.clientX - left) / width) * 2 - 1
        @mouse.y = -((e.clientY - top) / height) * 2 + 1

        @trigger 'mousemove', @mouse, (if @intersection then @intersection.point else null), @button

    handleMouseOver: (e) =>
        @mouseOver = true
        @trigger 'mouseover'

    handleMouseOut: (e) =>
        @mouseOver = false
        @trigger 'mouseout'

    handleMouseDown: (e) =>
        if e.button is 0
            @button = e.button
            @trigger 'mousedown', @mouse, (if @intersection then @intersection.point else null), @button

    handleMouseUp: (e) =>
        @button = null
        @trigger 'mouseup', @mouse, (if @intersection then @intersection.point else null)

    update: (raycastObjects) ->
        if @mouseOver
            vector = new THREE.Vector3(@mouse.x, @mouse.y, 1)
            @projector.unprojectVector vector, @renderer.camera
            @raycaster.ray.set(@renderer.camera.position, vector.sub(@renderer.camera.position).normalize())

            intersections = @raycaster.intersectObjects raycastObjects
            @intersection = if intersections.length > 0 then intersections[0] else null


module.exports = MouseHandler
