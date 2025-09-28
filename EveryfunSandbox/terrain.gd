extends VoxelTerrain

func _ready():
	var gen := VoxelGeneratorNoise.new()
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_octaves = 4
	gen.noise = noise
	generator = gen
