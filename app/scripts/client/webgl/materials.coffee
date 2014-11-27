THREE = require 'three'

types = {
    road: new THREE.Color 0x555555
    residential: new THREE.Color 0x00ff00
    industrial: new THREE.Color 0xffff00
    commercial: new THREE.Color 0x0000ff
    powerline: new THREE.Color 0xff5333
}

typeIndexes = {
    'road': 0
    'residential': 1
    'industrial': 2
    'commercial': 3
    'powerline': 4
}

materials = [
    new THREE.MeshLambertMaterial { color: types['road'] }
    new THREE.MeshLambertMaterial { color: types['residential'] }
    new THREE.MeshLambertMaterial { color: types['industrial'] }
    new THREE.MeshLambertMaterial { color: types['commercial'] }
    new THREE.MeshLambertMaterial { color: types['powerline'] }
]

module.exports = {
	types: types
	typeIndexes: typeIndexes
	materials: materials
}
