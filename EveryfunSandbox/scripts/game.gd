extends Node

var terrain
var player
var blockLibrary

var soundList = {}
var blockList = []
var blockIDs = {}

func loadResource(resourcePath):
	return load(resourcePath)

func playSound(sound, position: Vector3, parent):
	var audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.stream = sound.stream
	if position != null:
		audioPlayer.position = position
		if parent:
			parent.add_child(audioPlayer)
		else:
			terrain.add_child(audioPlayer)
	else:
		player.add_child(audioPlayer)

	audioPlayer.play()
	audioPlayer.connect("finished", Callable(audioPlayer, "queue_free"))

func getVoxelPositionFromGlobalPosition(position: Vector3):
	pass
	
func getGlobalPositionFromVoxelPosition(position: Vector3):
	pass

# ------------------------------------------------- backend

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
	terrain = get_node("/root/main/VoxelLodTerrain")
	player = get_node("/root/main/player")
	
	_addFolder("res://game")
	
	blockLibrary = _getLibrary()
	
func _addFolder(path):
	var list = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("/sounds.json")))
	if list:
		for sound in list:
			var audioStreamRandomizer = AudioStreamRandomizer.new()
			
			for listItem in sound.list:
				var weight = 1.0
				if listItem.has("weight"):
					weight = listItem.weight
				audioStreamRandomizer.add_stream(-1, loadResource(listItem.path), weight)
			
			if sound.has("random_pitch"):
				audioStreamRandomizer.random_pitch = sound.random_pitch
				
			if sound.has("random_volume_offset_db"):
				audioStreamRandomizer.random_volume_offset_db = sound.random_volume_offset_db
				
			if sound.has("playback_mode"):
				audioStreamRandomizer.playback_mode = sound.playback_mode
			
			sound.stream = audioStreamRandomizer
			
			soundList[sound.name] = sound

	list = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("/blocks.json")))
	if list:
		for item in list:
			if item.has("texture"):
				item.texture = loadResource(path.path_join(item.texture))
			
			if item.has("name"):
				blockIDs[item.name] = blockList.size()
			
			blockList.append(item)

func _getLibrary():
	var library = VoxelBlockyLibrary.new()
	
	for block in blockList:
		var blockModel
		if block.has("texture"):
			var material = ShaderMaterial.new()
			material.shader = _shader
			if block.has("no_texture_filter") and block.no_texture_filter:
				material.set_shader_parameter("diff_texture_no_filter", block.texture)
				material.set_shader_parameter("no_filter", true)
			else:
				material.set_shader_parameter("diff_texture", block.texture)
				material.set_shader_parameter("no_filter", false)
			
			var textureMode
			if block.has("texture_mode"):
				textureMode = _textureModes[block.texture_mode]
			else:
				textureMode = _textureModes[1]
			
			blockModel = VoxelBlockyModelCube.new()
			blockModel.atlas_size_in_tiles = textureMode[0]
			blockModel.set_material_override(0, material)
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_X, textureMode[1])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_X, textureMode[2])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Y, textureMode[3])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Y, textureMode[4])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_NEGATIVE_Z, textureMode[5])
			blockModel.set_tile(VoxelBlockyModel.Side.SIDE_POSITIVE_Z, textureMode[6])
		else:
			blockModel = VoxelBlockyModelEmpty.new()
		
		library.add_model(blockModel)
	
	return library
