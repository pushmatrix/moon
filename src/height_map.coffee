class Milk.HeightMap extends Milk
	constructor: (imageURL) ->
		super

		@notReady()
		@image = new Image()
		@image.onload = => @ready()
		@image.src = imageURL if imageURL

	stage: ->
		width = @image.width
		height = @image.height
		rows = height - 1
		cols = width - 1

		@metrics = {
			width: width
			height: height
			rows: rows
			cols: cols
			cellWidth: (rows + 1) / height
			cellHeight: (cols + 1) / width
		}

		geo = new THREE.PlaneGeometry width, height, rows, cols
		geo.dynamic = true

		@applyHeightMapToGeometry geo
		geo

	applyHeightMapToGeometry: (geo) ->
		@heightDataFromImage() if not @heightData

		heightData = @heightData
		for vertex, i in geo.vertices
			vertex.y = heightData[i]

		geo.computeFaceNormals()

	heightAtPosition: (x, z) ->
		@heightDataFromImage() if not @heightData

		numCols = @metrics.cols
		numRows = @metrics.rows
		cellWidth = @metrics.cellWidth
		cellHeight = @metrics.cellHeight

		x += numCols * cellWidth * 0.5
		z += numRows * cellHeight * 0.5

		gridX = x / cellWidth
		gridZ = z / cellHeight

		col0 = Math.floor(gridX)
		row0 = Math.floor(gridZ)
		col1 = col0 + 1
		row1 = row0 + 1


		# make sure that the cell coordinates don't fall
		# outside the height field.
		if col1 > numCols
			col1 = 0
		if row1 > numRows
			row1 = 0

		# get the four corner heights of the cell from the height field
		h00 = @heightData[col0 + row0 * (numCols + 1)]
		h01 = @heightData[col1 + row0 * (numCols + 1)]
		h11 = @heightData[col1 + row1 * (numCols + 1)]
		h10 = @heightData[col0 + row1 * (numCols + 1)]

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


	heightDataFromImage: ->
		width = @image.width
		height = @image.height

		canvas = document.createElement 'canvas'
		canvas.width = width
		canvas.height = height

		context = canvas.getContext '2d'
		context.drawImage @image, 0, 0

		size = width * height
		heightData = new Float32Array size

		pixels = context.getImageData(0, 0, width, height).data
		pixelIndex = 0

		for pixel, i in pixels by 4
			all = pixel + pixels[i + 1] + pixels[i + 2]
			heightData[pixelIndex++] = all / 30

		@heightData = heightData
