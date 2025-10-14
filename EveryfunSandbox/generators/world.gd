extends VoxelGeneratorScript

var noise = []
var resources = []

var dirtOffset = 3
var dirtHeight = 16

var cavePercent = 0.3
var caveScale = 0.25

func _init():
	resources = [
		[0.05, game.blockIDs["glass"]],
		[0.1, game.blockIDs["dirt"]]
	]
	
	for i in range(2 + resources.size()):
		var lnoise = FastNoise2.new()
		lnoise.seed = 1000 + (i * 20)
		noise.append(lnoise)
		
	noise[1].noise_type = FastNoise2.TYPE_VALUE 

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
				
				var noiseValue = (noise[0].get_noise_2d_single(Vector2i(worldPos.x, worldPos.z)) + 1) / 2
				var terrainHeight = round(noiseValue * 15)

				var caveNoiseValue = (noise[1].get_noise_3d_single(worldPos / caveScale) + 1) / 2
				if caveNoiseValue < cavePercent:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y == terrainHeight:
					buffer.set_voxel_v(id_grass, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y < terrainHeight:
					var dirtNoiseValue = (noise[0].get_noise_2d_single(Vector2i(worldPos.x, worldPos.z)) + 1) / 2
					dirtNoiseValue *= dirtHeight
					dirtNoiseValue += dirtOffset
					var dirtPos = terrainHeight - worldPos.y
					if dirtPos <= dirtNoiseValue:
						buffer.set_voxel_v(id_dirt, localPos, VoxelBuffer.CHANNEL_TYPE)
					else:
						var finded = false
						var index = 0
						for resource in resources:
							var resourceNoiseValue = (noise[2 + index].get_noise_3d_single(worldPos) + 1) / 2
							if resourceNoiseValue < resource[0]:
								buffer.set_voxel_v(resource[1], localPos, VoxelBuffer.CHANNEL_TYPE)
								finded = true
							index += 1
								
						if not finded:
							buffer.set_voxel_v(id_stone, localPos, VoxelBuffer.CHANNEL_TYPE)
				else:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
