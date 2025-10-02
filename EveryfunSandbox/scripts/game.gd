extends Node

var terrain
var player
var camera
var blockLibrary

var soundList = {}
var musicList = []
var ambientList = []
var blockList = []
var blockIDs = {}

func loadResource(resourcePath):
	return load(resourcePath)

func playSound(sound, position: Vector3, parent=null):
	var audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.stream = sound.stream
	audioPlayer.unit_size = sound.get("unit_size", 1)
	audioPlayer.max_distance = sound.get("max_distance", 30)
	audioPlayer.attenuation_filter_cutoff_hz = sound.get("attenuation_filter_cutoff_hz", 5000)
	audioPlayer.volume_db = sound.get("volume_db", 0)
	
	audioPlayer.position = position
	if parent:
		parent.add_child(audioPlayer)
	else:
		terrain.add_child(audioPlayer)

	audioPlayer.play()
	audioPlayer.connect("finished", Callable(audioPlayer, "queue_free"))

func getVoxelPositionFromGlobalPosition(position: Vector3) -> Vector3i:
	return Vector3i(position - terrain.global_transform.origin)

func getGlobalPositionFromVoxelPosition(position: Vector3i) -> Vector3:
	return terrain.global_transform.origin + Vector3(position.x, position.y, position.z) + Vector3(0.5, 0.5, 0.5)

func isCellFree(position: Vector3) -> bool:
	var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.8, 0.8, 0.8)
	query.shape = shape
	query.transform = Transform3D(Basis(), getGlobalPositionFromVoxelPosition(position))
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	return results.size() == 0
	
func setMouseEnabled(mouseEnabled):
	if mouseEnabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	camera = get_node("/root/main/player/camera")
	
	_addFolder("res://game")
	
	blockLibrary = _getLibrary()
	_initMusic()
	_initAmbient()
	
func _musicEnd(musicPlayer):
	timers.setTimeout(func():
		musicPlayer.play()
	, randi_range(3, 30))
	
func _ambientEnd(ambientPlayer):
	ambientPlayer.play()

func _initMusic():
	var musicRandomizer = AudioStreamRandomizer.new()
	for music in musicList:
		musicRandomizer.add_stream(-1, music, 1)
	
	var musicPlayer = get_node("/root/main/music")
	musicPlayer.stream = musicRandomizer
	musicPlayer.play()
	musicPlayer.connect("finished", _musicEnd.bind(musicPlayer))
	
func _initAmbient():
	var ambientRandomizer = AudioStreamRandomizer.new()
	for ambient in ambientList:
		ambientRandomizer.add_stream(-1, ambient, 1)
	
	var ambientPlayer = get_node("/root/main/ambient")
	ambientPlayer.stream = ambientRandomizer
	ambientPlayer.play()
	ambientPlayer.connect("finished", _ambientEnd.bind(ambientPlayer))
	
func _addFolder(path):
	var list = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("/sounds.json")))
	if list:
		for sound in list:
			var audioStreamRandomizer = AudioStreamRandomizer.new()
			
			for listItem in sound.list:
				var weight = 1.0
				if listItem.has("weight"):
					weight = listItem.weight
				audioStreamRandomizer.add_stream(-1, loadResource(path.path_join(listItem.path)), weight)
			
			if sound.has("random_pitch"):
				audioStreamRandomizer.random_pitch = sound.random_pitch
				
			if sound.has("random_volume_offset_db"):
				audioStreamRandomizer.random_volume_offset_db = sound.random_volume_offset_db
				
			if sound.has("playback_mode"):
				audioStreamRandomizer.playback_mode = sound.playback_mode
			
			sound.stream = audioStreamRandomizer
			
			soundList[sound.name] = sound
			
	list = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("/music.json")))
	if list:
		for music in list:
			musicList.append(loadResource(path.path_join(music)))
			
	list = JSON.parse_string(FileAccess.get_file_as_string(path.path_join("/ambient.json")))
	if list:
		for ambient in list:
			ambientList.append(loadResource(path.path_join(ambient)))

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
			if block.get("texture_no_filter", false):
				material.set_shader_parameter("diff_texture_no_filter", block.texture)
				material.set_shader_parameter("no_filter", true)
			else:
				material.set_shader_parameter("diff_texture", block.texture)
				material.set_shader_parameter("no_filter", false)
			
			var textureMode = _textureModes[block.get("texture_mode", 1)]
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
