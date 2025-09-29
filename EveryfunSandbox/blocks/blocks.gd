extends Node

var atlas_size = Vector2i(2, 2)
var material
var library

var blockslist = [
	
]

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://blocks/blocks.gdshader")
	
	library = _get_library()

func _get_library():
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	var block = VoxelBlockyModelCube.new()
	block.atlas_size_in_tiles = atlas_size
	block.set_material_override(0, blocks.material)
	library.add_model(block)
	
	var block2 = VoxelBlockyModelCube.new()
	block2.atlas_size_in_tiles = atlas_size
	block2.set_material_override(0, blocks.material)
	block2.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Y, Vector2i(1, 1))
	library.add_model(block2)
	
	return library
