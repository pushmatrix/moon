class Sprite extends THREE.Object3D
  SCALE_FACTOR = 0.0001

  constructor: (fileName)->
    super()

    @texture = THREE.ImageUtils.loadTexture "/public/#{fileName}", null, =>
      @mesh = new THREE.Sprite( { map: @texture, size: SCALE_FACTOR, useScreenCoordinates: false, color: 0xffffff } )
  
      @mesh.scale.x = @texture.image.width * SCALE_FACTOR
      @mesh.scale.y = @texture.image.height * SCALE_FACTOR

      @add(@mesh)