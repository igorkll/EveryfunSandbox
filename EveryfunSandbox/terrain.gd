extends VoxelTerrain

func _ready():
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_octaves = 4
	
	var gen := VoxelGeneratorNoise.new()
	gen.noise = noise
	
	self.mesher = VoxelMesherTransvoxel.new()
	self.generator = gen
