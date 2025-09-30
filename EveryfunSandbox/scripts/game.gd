extends Node

var blockLibrary

var soundList = {}
var blockList = []
var blockIDs = {}

var _shader = preload("res://shaders/blocks.gdshader")

var _textureModes = [
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
	blockIDs["air"] = 0
	_addFolder("res://game")
	
	blockLibrary = _getLibrary()
	
func _addFolder(path):
	var list = JSON.parse_string(FileAccess.get_file_as_string(path + "/sounds.json"))
	if list:
		for item in list:
			soundList[item.name] = item

	list = JSON.parse_string(FileAccess.get_file_as_string(path + "/blocks.json"))
	if list:
		for item in list:
			item.texture = load(path + "/" + item.texture)
			
			blockList.append(item)
			if item.has("name"):
				blockIDs[item.name] = blockList.size()

func _getLibrary():
	var library = VoxelBlockyLibrary.new()
	
	var air = VoxelBlockyModelEmpty.new()
	library.add_model(air)
	
	for block in blockList:
		var material = ShaderMaterial.new()
		material.shader = _shader
		if block.has("no_texture_filter") and block.no_texture_filter:
			material.set_shader_parameter("diff_texture_no_filter", block.texture)
			material.set_shader_parameter("no_filter", true)
		else:
			material.set_shader_parameter("diff_texture", block.texture)
			material.set_shader_parameter("no_filter", false)
		
		var textureMode = _textureModes[block.texture_mode]
		
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
