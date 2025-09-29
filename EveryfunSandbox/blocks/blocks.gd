extends Node

var shader
var library

var blocklist = []

var textureModes = [
	[
		Vector2i(3, 3),
		
		Vector2i(0, 1),
		Vector2i(2, 1),
		Vector2i(0, 0),
		Vector2i(1, 1),
		Vector2i(1, 2),
		Vector2i(1, 0)
	],
	[
		Vector2i(1, 1),
		
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0)
	]
]

func _ready():
	_addBlockFolder("res://blocks")
	
	shader = preload("res://blocks/blocks.gdshader")
	library = _get_library()
	
func _addBlockFolder(path):
	var jsonPath = path + "/blocks.json"
	var list = JSON.parse_string(FileAccess.get_file_as_string(jsonPath))
	if list:
		for item in list:
			item.texture = load(path + "/" + item.texture)
			blocklist.append(item)

func _get_library():
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	for block in blocklist:
		var material = ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter("diff_texture", block.texture)
		
		var textureMode = textureModes[block.texture_mode]
		
		var blockModel = VoxelBlockyModelCube.new()
		blockModel.atlas_size_in_tiles = textureMode[0]
		blockModel.set_material_override(0, material)
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_X, textureMode[1])
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_X, textureMode[2])
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Y, textureMode[3])
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Y, textureMode[4])
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Z, textureMode[5])
		blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Z, textureMode[6])
		library.add_model(blockModel)
	
	return library
