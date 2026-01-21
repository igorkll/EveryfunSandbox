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

var cavePercentTop = 0.1
var cavePercent = 0.6
var maxCavesAtHeight = -200
var caveScale = 0.25

var grassCutPos = 64.0
var grassCutScale = 0.5
var grassCutPow = 4


var caveHoise
var dirtHoise
var grassCutHoise
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
	
	var seed = saves.currentWorldData.initialWorldData.seed
	
	caveHoise = FastNoise2.new()
	caveHoise.seed = seed
	caveHoise.noise_type = FastNoise2.TYPE_VALUE
	
	dirtHoise = FastNoise2.new()
	dirtHoise.seed = seed + 10
	
	grassCutHoise = FastNoise2.new()
	grassCutHoise.seed = seed + 20

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
				var local2dPos = Vector2(worldPos.x, worldPos.z)

				var terrainHeight = 0.0
				for t in terrainHeightValues:
					var n = terrainNoises[t[2]].get_noise_2d_single(local2dPos / t[1])
					n = (n + 1.0) / 2
					if t[3] > 0:
						n = pow(n, t[3])
					terrainHeight += n * t[0]
				terrainHeight = int(round(terrainHeight))

				var grassCut = worldPos.y > grassCutPos
				if !grassCut:
					var grassCutPercent = worldPos.y / grassCutPos
					var value = (grassCutHoise.get_noise_2d_single(local2dPos / grassCutScale) + 1) / 2
					value = 1 - pow(value, grassCutPow)
					grassCut = value < grassCutPercent
					
				var localCavePercent = remap(worldPos.y, maxCavesAtHeight, 0, cavePercent, cavePercentTop)
				if localCavePercent > cavePercent:
					localCavePercent = cavePercent
				
				var caveNoiseValue = (caveHoise.get_noise_3d_single(worldPos / caveScale) + 1) / 2
				if caveNoiseValue < localCavePercent:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y == terrainHeight && !grassCut:
					buffer.set_voxel_v(id_grass, localPos, VoxelBuffer.CHANNEL_TYPE)
				elif worldPos.y <= terrainHeight:
					var dirtNoiseValue = (dirtHoise.get_noise_2d_single(local2dPos) + 1) / 2
					dirtNoiseValue *= dirtHeight
					dirtNoiseValue += dirtOffset
					var dirtPos = terrainHeight - worldPos.y
					if dirtPos <= dirtNoiseValue  && !grassCut:
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
