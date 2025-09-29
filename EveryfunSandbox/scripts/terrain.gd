extends VoxelLodTerrain

func _ready():
	var gen = VoxelGeneratorWaves.new()
	gen.channel = VoxelBuffer.CHANNEL_TYPE
	
	var mesher = VoxelMesherBlocky.new()
	
	mesher.library = get_block_library()
	
	self.mesher = mesher
	self.generator = gen
	self.view_distance = 2048
	self.lod_distance = 256

func get_block_library():
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	var block = VoxelBlockyModelCube.new()
	block.set_material_override(0, blocks.material)
	library.add_model(block)
	
	return library
