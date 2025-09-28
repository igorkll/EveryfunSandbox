extends VoxelTerrain

func _ready():
	var gen = VoxelGeneratorWaves.new()
	gen.height_range = 50
	
	var mesher = VoxelMesherBlocky.new()
	
	var library = VoxelBlockyLibrary.new()
	setup_block_library(library)
	mesher.library = library
	
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
