class window.TextObject extends THREE.Object3D
  @TEXT_OPTIONS = {
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
  }

  constructor: (@message) ->
    super()

    @faceMaterial = new THREE.MeshFaceMaterial
    @frontMaterial = new THREE.MeshBasicMaterial color: 0xffffff, shading: THREE.FlatShading
    @sideMaterial = new THREE.MeshBasicMaterial color: 0xbbbbbb, shading: THREE.SmoothShading

    geo = new THREE.TextGeometry message, TextObject.TEXT_OPTIONS
    geo.materials = [@frontMaterial, @sideMaterial]
    geo.computeBoundingBox()
    geo.computeVertexNormals()

    @mesh = mesh = new THREE.Mesh geo, @faceMaterial
    mesh.scale.x = mesh.scale.y = mesh.scale.z = 0.015

    @width = geo.boundingBox.max.x * mesh.scale.x / 2
    @add mesh

  positionOver: (object) ->
    @position.x = object.position.x
    @position.y = object.position.y + object.boundingBox.max.y + 0.5
    @position.z = object.position.z

    @lookAt game.camera.position
    @translateX -@width
