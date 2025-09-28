extends VoxelTerrain

func _ready():
	var gen = VoxelGeneratorNoise.new()
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_octaves = 4
	gen.noise = noise
	
	var mesher = VoxelMesherTransvoxel.new()
	
	
	self.mesher = mesher
	self.generator = gen

func setup_block_library(library: VoxelBlockyLibrary):
	# Камень
	var stone = VoxelBlockyModel.new()
	stone.color = Color("8b8b8b")
	library.add_model(stone)
	
	# Земля
	var dirt = VoxelBlockyModel.new()
	dirt.color = Color("5d4037")
	library.add_model(dirt)
	
	# Трава
	var grass = VoxelBlockyModel.new()
	grass.color = Color("4caf50")
	library.add_model(grass)
