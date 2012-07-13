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

	constructor: ->
		super

		@value = ''
		@options = Milk.mixin {}, DEFAULT_OPTIONS

		@faceMaterial = new THREE.MeshFaceMaterial
		@frontMaterial = new THREE.MeshBasicMaterial color: 0xffffff, shading: THREE.FlatShading
		@sideMaterial = new THREE.MeshBasicMaterial color: 0xbbbbbb, shading: THREE.SmoothShading

		@scale = 0.015

	stage: ->
		super

		geo = new THREE.TextGeometry @value, @options
		geo.materials = [@frontMaterial, @sideMaterial]
		geo.computeBoundingBox()
		geo.computeVertexNormals()

		@midX = geo.boundingBox.max.x * @scale / 2

		mesh = new THREE.Mesh geo, @faceMaterial
		mesh.scale = new THREE.Vector3 @scale, @scale, @scale
		@exportObject mesh

		@scene.add mesh


	unstage: ->
		@scene.remove @object3D

class Milk.OverheadText extends Milk.Component
	setText: (string) ->
		@clearText()
		@text = new Milk.Text
		@text.value = string

	stageText: ->
		@text.stage()

	update: ->
		return if not @text
		position = @text.object3D.position
		position.x = @object3D.position.x
		position.y = @object3D.position.y + 1.5
		position.z = @object3D.position.z

		@text.object3D.lookAt game.level.camera.position
		@text.object3D.translateX -@text.midX

	clearText: (string) ->
		return if !@text or (string? and @text?.value isnt string)
		@text.unstage()
		@text = null

