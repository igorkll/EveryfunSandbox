extends VoxelGeneratorScript

var resources = []

var terrainHeightValues = [
	[
		256,  # height
		10,    # scale
		0,    # noise index,
		5     # pow
	],
	[
		32,   # height
		5,    # scale
		1,    # noise index,
		3     # pow
	],
	[
		4,
		1,
		2,
		0
	]
]

var dirtOffset = 3
var dirtHeight = 16

var cavePercent = 0
var caveScale = 0.25

var caveHoise
var dirtHoise
var resourcesNoises = []
var terrainNoises = []

func createMountainNoises(seed):
	var lnoise = FastNoise2.new()
	lnoise.period = 5000
	lnoise.noise_type = FastNoise2.TYPE_OPEN_SIMPLEX_2
	lnoise.seed = seed + 10 + (5000 * 2)
	terrainNoises.append(lnoise)
	
	lnoise = FastNoise2.new()
	lnoise.period = 2000
	lnoise.noise_type = FastNoise2.TYPE_OPEN_SIMPLEX_2
	lnoise.seed = seed + 20 + (5000 * 2)
	terrainNoises.append(lnoise)
	
	lnoise = FastNoise2.new()
	lnoise.period = 32
	lnoise.seed = seed + 30 + (5000 * 2)
	terrainNoises.append(lnoise)

func _init():
	resources = [
		[0.02, blockUtils.list_name2id["lazuli"]],
		[0.01, blockUtils.list_name2id["gold"]],
		[0.001, blockUtils.list_name2id["uranium"]],
		[0.1, blockUtils.list_name2id["dirt"]]
	]
	
	var seed = 1000
	
	caveHoise = FastNoise2.new()
	caveHoise.seed = seed
	caveHoise.noise_type = FastNoise2.TYPE_VALUE
	
	dirtHoise = FastNoise2.new()
	dirtHoise.seed = seed + 10

	for i in range(resources.size()):
		var lnoise = FastNoise2.new()
		lnoise.seed = seed + (i * 50) + 5000
		resourcesNoises.append(lnoise)
		
	createMountainNoises(seed)

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	var size = buffer.get_size()
	var scale = 1 << lod
	
	var id_grass = blockUtils.list_name2id["grass"]
	var id_dirt = blockUtils.list_name2id["dirt"]
	var id_stone = blockUtils.list_name2id["stone"]
	
	for ix in range(size.x):
		for iy in range(size.y):
			for iz in range(size.z):
				var localPos = Vector3i(ix, iy, iz)
				var worldPos = position + (localPos * scale)

				var heightOffset = 0
				for terrainHeightArr in terrainHeightValues:
					var noiseValue = (terrainNoises[terrainHeightArr[2]].get_noise_2d_single(Vector2i(worldPos.x, worldPos.z) / terrainHeightArr[1]) + 1) / 2
					if terrainHeightArr[3] > 0:
						noiseValue = pow(noiseValue, terrainHeightArr[3])
					
					var terrainHeight = heightOffset + round(noiseValue * terrainHeightArr[0])
					heightOffset = terrainHeight
					
					var caveNoiseValue = (caveHoise.get_noise_3d_single(worldPos / caveScale) + 1) / 2
					if caveNoiseValue < cavePercent:
						buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
					elif worldPos.y == terrainHeight:
						buffer.set_voxel_v(id_grass, localPos, VoxelBuffer.CHANNEL_TYPE)
					elif worldPos.y < terrainHeight:
						var dirtNoiseValue = (dirtHoise.get_noise_2d_single(Vector2i(worldPos.x, worldPos.z)) + 1) / 2
						dirtNoiseValue *= dirtHeight
						dirtNoiseValue += dirtOffset
						var dirtPos = terrainHeight - worldPos.y
						if dirtPos <= dirtNoiseValue:
							buffer.set_voxel_v(id_dirt, localPos, VoxelBuffer.CHANNEL_TYPE)
						else:
							var finded = false
							var index = 0
							for resource in resources:
								var resourceNoiseValue = (resourcesNoises[index].get_noise_3d_single(worldPos) + 1) / 2
								if resourceNoiseValue < resource[0]:
									buffer.set_voxel_v(resource[1], localPos, VoxelBuffer.CHANNEL_TYPE)
									finded = true
								index += 1
									
							if not finded:
								buffer.set_voxel_v(id_stone, localPos, VoxelBuffer.CHANNEL_TYPE)
