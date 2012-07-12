class Moon extends THREE.Object3D
  constructor: ->
    super()

    img = new Image()
    img.onload = =>

      @height = img.height
      @width = img.width
      @numRows = @height - 1
      @numCols = @width - 1

      @cellWidth = (@numRows + 1) / @height
      @cellHeight = (@numCols + 1) / @width
      @geometry = new THREE.PlaneGeometry(@width, @height, @numRows, @numCols)
      @geometry.dynamic = true

      @heights = @getHeightData(img)
      for vertex in @geometry.vertices
        vertex.y = @heights[_i]
      @geometry.computeFaceNormals()


      planeTex = THREE.ImageUtils.loadTexture("public/dirt.jpg")
      planeTex.wrapS = planeTex.wrapT = THREE.RepeatWrapping
      planeTex.repeat.set( 10, 10 )

      @material = new THREE.MeshLambertMaterial(map: planeTex, shading: THREE.SmoothShading, specular: 0x0, ambient: 0xeeeeee, diffuse: 0x0, color: 0x555555, shininess: 32)
      @mesh = new THREE.Mesh(@geometry, @material)
      @add(@mesh)

    img.src = 'public/map.jpg'

  getHeight: (x, z) ->
    return 0 unless @heights

    x += @numCols * @cellWidth * 0.5
    z += @numRows * @cellHeight * 0.5

    gridX = x / @cellWidth
    gridZ = z / @cellHeight

    col0 = Math.floor(gridX)
    row0 = Math.floor(gridZ)
    col1 = col0 + 1
    row1 = row0 + 1


    # make sure that the cell coordinates don't fall
    # outside the height field.
    if col1 > @numCols
      col1 = 0
    if row1 > @numRows
      row1 = 0

    # get the four corner heights of the cell from the height field
    h00 = @heights[col0 + row0 * (@numCols + 1)]
    h01 = @heights[col1 + row0 * (@numCols + 1)]
    h11 = @heights[col1 + row1 * (@numCols + 1)]
    h10 = @heights[col0 + row1 * (@numCols + 1)]

    # calculate the position of the camera relative to the cell.
    # note, that 0 <= tx, ty <= 1.
    tx = gridX - col0
    ty = gridZ - row0

    # the next step is to perform a bilinear interpolation
    # to compute the height of the terrain directly below
    # the object.
    txty = tx * ty

    height = h00 * (1 - ty - tx + txty) + h01 * (tx - txty) + h11 * txty + h10 * (ty - txty)
    height


  getHeightData: (img) ->
    canvas = document.createElement('canvas')
    canvas.width = img.width
    canvas.height = img.height
    context = canvas.getContext('2d')

    size = img.width * img.height
    data = new Float32Array(size)

    context.drawImage(img, 0, 0)

    imgd = context.getImageData(0, 0, img.width, img.height)
    pix = imgd.data

    j = 0
    for pic, i in pix by 4
      all = pic + pix[i + 1] + pix[i + 2]
      data[j++] = all / 30

    data
