extends VoxelGeneratorScript

var noise

func _init():
	noise = FastNoise2.new()

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	var size = buffer.get_size()
	var scale = 1 << lod
	
	var id_grass = game.blockIDs["grass"]
	var id_stone = game.blockIDs["stone"]
	
	for ix in range(size.x):
		for iy in range(size.y):
			for iz in range(size.z):
				var localPos = Vector3i(ix, iy, iz)
				var worldPos = position + (localPos * scale)
				
				var noiseValue = (noise.get_noise_2d_single(Vector2i(worldPos.x, worldPos.z)) + 1) / 2
				var terrainHeight = round(noiseValue * 15)

				if worldPos.y == terrainHeight:
					buffer.set_voxel_v(id_grass, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y < terrainHeight:
					buffer.set_voxel_v(id_stone, localPos, VoxelBuffer.CHANNEL_TYPE)
				else:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
