extends VoxelTerrain

func _ready():
	var gen = VoxelGeneratorWaves.new()
	gen.channel = VoxelBuffer.CHANNEL_TYPE
	
	var mesher = VoxelMesherBlocky.new()
	
	var library = VoxelBlockyLibrary.new()
	setup_block_library(library)
	mesher.library = library
	
	self.mesher = mesher
	self.generator = gen

func setup_block_library(library: VoxelBlockyLibrary):
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	var dirt = VoxelBlockyModelCube.new()
	dirt.color = Color("5d4037")
	library.add_model(dirt)
	
	var grass = VoxelBlockyModelCube.new()
	grass.color = Color("4caf50")
	library.add_model(grass)
