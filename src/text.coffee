class Milk.Text extends Milk
	DEFAULT_OPTIONS =
		size: 42
		height: 64
		curveSegments: 4
		font: "helvetiker"
		weight: "normal"
		style: "normal"
		bevelEnabled: true
		bevelThickness: 1
		bevelSize: 1
		bend: true
		material: 0
		extrudeMaterial: 1

	constructor: (message = '', options = {}) ->
		@message = message
		@options = Milk.mixin {}, DEFAULT_OPTIONS, options

		@faceMaterial = new THREE.MeshFaceMaterial
		@frontMaterial = new THREE.MeshBasicMaterial color: 0xffffff, shading: THREE.FlatShading
		@sideMaterial = new THREE.MeshBasicMaterial color: 0xbbbbbb, shading: THREE.SmoothShading

		@scale = 0.015

	render: ->
		geo = new THREE.TextGeometry @message, @options
		geo.materials = [@frontMaterial, @sideMaterial]
		geo.computeBoundingBox()
		geo.computeVertexNormals()

		@midX = geo.boundingBox.max.x * @scale / 2

		mesh = new THREE.Mesh geo, @faceMaterial
		mesh.scale = new THREE.Vector3 @scale, @scale, @scale
		@exportObject mesh

	update: ->


	positionOver: (object) ->
		@position.x = object.position.x
		@position.y = object.position.y + object.boundingBox.max.y + 0.5
		@position.z = object.position.z

		@lookAt game.camera.position
		@translateX -@width

class Milk.OverheadText

