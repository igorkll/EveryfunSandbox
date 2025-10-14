extends VoxelGeneratorScript

var noise
var resources = []

func _init():
	noise = FastNoise2.new()
	resources = [
		[0.05, game.blockIDs["glass"]],
		[0.1, game.blockIDs["dirt"]]
	]

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	var size = buffer.get_size()
	var scale = 1 << lod
	
	var id_grass = game.blockIDs["grass"]
	var id_dirt = game.blockIDs["dirt"]
	var id_stone = game.blockIDs["stone"]
	
	for ix in range(size.x):
		for iy in range(size.y):
			for iz in range(size.z):
				var localPos = Vector3i(ix, iy, iz)
				var worldPos = position + (localPos * scale)
				
				var noiseValue = (noise.get_noise_2d_single(Vector2i(worldPos.x, worldPos.z)) + 1) / 2
				var terrainHeight = round(noiseValue * 15)

				var caveNoiseValue = (noise.get_noise_3d_single(worldPos + Vector3i(0, 10000, 0)) + 1) / 2
				if caveNoiseValue < 0.2:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y == terrainHeight:
					buffer.set_voxel_v(id_grass, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y < terrainHeight:
					var finded = false
					var index = 0
					for resource in resources:
						index += 1
						var resourceNoiseValue = (noise.get_noise_3d_single(worldPos + Vector3i(0, 10000 * (index + 1), 0)) + 1) / 2
						if resourceNoiseValue < resource[0]:
							buffer.set_voxel_v(resource[1], localPos, VoxelBuffer.CHANNEL_TYPE)
							finded = true
							
					if not finded:
						buffer.set_voxel_v(id_stone, localPos, VoxelBuffer.CHANNEL_TYPE)
				else:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
