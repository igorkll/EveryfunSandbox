extends VoxelLodTerrain

func _ready():
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_octaves = 4

	var gen = VoxelGeneratorNoise2D.new()
	gen.channel = VoxelBuffer.CHANNEL_TYPE
	gen.noise = noise
	gen.height_range = 50
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = blocks.library
	
	self.mesher = mesher
	self.generator = gen
	self.view_distance = 2048
	self.lod_distance = 256
