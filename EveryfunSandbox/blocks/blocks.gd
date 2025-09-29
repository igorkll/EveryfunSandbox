extends Node

var shader
var material
var library

var blocklist = [
	{
		texture = "res://blocks/stone/texture.png"
	}
]

func _ready():
	shader = load("res://blocks/blocks.gdshader")
	material = _get_material()
	library = _get_library()




func _generate_atlas():
	for block in blocklist:
		block.atlas_size = Vector2i(2, 2)
	
func _get_material():
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("diff_texture", _generate_atlas())
	
	return material

func _get_library():
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	for block in blocklist:
		var blockModel = VoxelBlockyModelCube.new()
		blockModel.atlas_size_in_tiles = block.atlas_size
		blockModel.set_material_override(0, material)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_X, block.atlas_neg_x)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_X, block.atlas_pos_x)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Y, block.atlas_neg_y)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Y, block.atlas_pos_y)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Z, block.atlas_neg_z)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Z, block.atlas_pos_z)
		library.add_model(blockModel)
	
	return library
