
THREE = require 'three'


class MouseHandler
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

    handleMouseOver: (e) =>
        @mouseOver = true

    handleMouseOut: (e) =>
        @mouseOver = false

    handleMouseDown: (e) =>
        if e.button is 0
            @button = true

    handleMouseUp: (e) =>
        @button = false

    update: (raycastObjects) ->
        if @mouseOver
            vector = new THREE.Vector3(@mouse.x, @mouse.y, 1)
            @projector.unprojectVector vector, @renderer.camera
            @raycaster.ray.set(@renderer.camera.position, vector.sub(@renderer.camera.position).normalize())

            intersections = @raycaster.intersectObjects raycastObjects
            @intersection = if intersections.length > 0 then intersections[0] else null


module.exports = MouseHandler
