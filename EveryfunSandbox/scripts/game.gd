extends Node

var mainNode
var terrain
var player
var camera
var blockLibrary
var settings
var miscData = {}
var muteAllExceptMusic = false

var defaultSettings = {
	"statistics": {
		"game_session_counter": 0
	},
	"audio": {
		"volume": {
			"Master": 0.7,
			"Music": 0.3,
			"Ambient": 0.2,
			"Effects": 1
		}
	},
	"control": {
		"joystick": {
			"deadzone": 0.05,
			"sensitivity": 1
		},
		"mouse": {
			"sensitivity": 1
		}
	},
	"gui": {
		"scale": 1
	}
}

var soundList = {}
var musicList = []
var ambientList = []
var blockList = []
var blockIDs = {}

func loadResource(resourcePath):
	return load(resourcePath)

func playSound(sound, position: Vector3, parent=null, channel="Effects"):
	var audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = channel
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

func formatType(value):
	var valueType
	match typeof(value):
		TYPE_STRING:
			valueType = "\"%s\"" % value
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR, TYPE_RECT2:
			valueType = str(value)
		TYPE_BOOL:
			valueType = str(value).to_lower()
		TYPE_NIL:
			valueType = "null"
		_:
			valueType = str(value)
	return valueType
	
func formatCall(funcname, ...args) -> String:
	var parts := []
	for arg in args:
		parts.append(formatType(arg))
	return "%s(%s)" % [funcname, ", ".join(parts)]
	
func logCall(funcname, ...args):
	print(formatCall(funcname, args))
	
func logCallResult(funcname, result):
	print("---- %s -> %s" % [funcname, formatType(result)])
	
func setAudioChannelVolume(bus, multiplier):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(multiplier))
	
func applyAudioSettings():
	for key in settings.audio.volume.keys():
		setAudioChannelVolume(key, settings.audio.volume[key])
	game.setAudioChannelVolume("NotMusic", 0 if muteAllExceptMusic else 1)
	
func setMuteAllExceptMusic(mute):
	muteAllExceptMusic = mute
	applyAudioSettings()

func defaultSettingsInit():
	var currentScreen = DisplayServer.window_get_current_screen()
	if currentScreen < 0:
		currentScreen = 0
	
	var resolution = DisplayServer.screen_get_size(currentScreen)
	defaultSettings.gui.scale = resolution.x / 1920

func loadSettings():
	settings = {}
	if filesystem.isFile(consts.settings_path):
		settings = filesystem.readJson(consts.settings_path)
	defaultSettingsInit()
	settings = funcs.merge_dicts(settings, defaultSettings)
	settings.statistics.game_session_counter = settings.statistics.game_session_counter + 1;
	
	applyAudioSettings()

func saveSettings():
	filesystem.writeJson(consts.settings_path, settings)

func joystickProcess(value):
	var negative = value < 0
	value = abs(value)
	if value < settings.control.joystick.deadzone:
		value = 0
	if negative:
		return -value
	return value

func getJoystickValues():
	var axisLX = 0
	var axisLY = 0
	var axisRX = 0
	var axisRY = 0
	var axisTL = 0
	var axisTR = 0
	for device in range(Input.get_connected_joypads().size()):
		axisLX += joystickProcess(Input.get_joy_axis(device, JOY_AXIS_LEFT_X))
		axisLY += joystickProcess(Input.get_joy_axis(device, JOY_AXIS_LEFT_Y))
		axisRX += joystickProcess(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X))
		axisRY += joystickProcess(Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y))
		axisTL += joystickProcess(Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT))
		axisTR += joystickProcess(Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT))
	return [axisLX, axisLY, axisRX, axisRY, axisTL, axisTR]

func getLeftJoystickValues():
	var joystickValues = getJoystickValues()
	return [joystickValues[0], joystickValues[1]]
	
func getRightJoystickValues():
	var joystickValues = getJoystickValues()
	return [joystickValues[2], joystickValues[3]]
	
func getTriggerJoystickValues():
	var joystickValues = getJoystickValues()
	return [joystickValues[4], joystickValues[5]]
	
var gameMessageBase = preload("res://gameMessage.tscn")
var gameMessagesContainer

# minShowTime can be used to delay deleting an item. for example, if you need to display a process that can run very quickly (and then you don't need to immediately delete the label), or it can take a long time (and then you need to remove it immediately when the process is completed)
func gameMessage(text, timeout=4, processAnimation=false, minShowTime=null):
	var message = gameMessageBase.instantiate()
	var label = message.find_child("label", true, false)
	label.text = text
	
	if timeout != null:
		message.timeout = timeout
		
	if minShowTime != null:
		message.minShowTime = minShowTime
	
	if processAnimation:
		message.processAnimation = true
	
	gameMessagesContainer.add_child(message)
	return message
	
func setScale(scale):
	get_tree().root.content_scale_factor = scale
	
func getScale():
	return get_tree().root.content_scale_factor

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
	mainNode = get_node("/root/main")
	player = get_node("/root/main/player")
	camera = get_node("/root/main/player/camera")
	gameMessagesContainer = mainNode.find_child("gameMessages", true, false)
	
	loadSettings()
	saveSettings() # update session counter
	
	_addFolder("res://game")
	
	blockLibrary = _getLibrary()
	_initMusic()
	_initAmbient()
	_initGui()

func _initGui():
	setScale(settings.gui.scale)

var _musicRandomizer

func _musicEnd(musicPlayer):
	timers.setTimeout(func():
		musicPlayer.stream = _musicRandomizer
		musicPlayer.play()
	, randi_range(3, 30))
	
func _ambientEnd(ambientPlayer):
	ambientPlayer.play()

func _initMusic():
	_musicRandomizer = AudioStreamRandomizer.new()
	for music in musicList:
		_musicRandomizer.add_stream(-1, music, 1)
	
	var musicStream = _musicRandomizer
	var session = settings.statistics.game_session_counter - 1
	if miscData.has("the_first_music_in_the_first_played_sessions"):
		if funcs.indexExistsInArray(miscData["the_first_music_in_the_first_played_sessions"], session):
			musicStream = loadResource(miscData["the_first_music_in_the_first_played_sessions"][session])
	
	var musicPlayer = get_node("/root/main/music")
	musicPlayer.stream = musicStream
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
	var list = filesystem.readJson(path.path_join("/misc.json"))
	if list:
		if list.has("the_first_music_in_the_first_played_sessions"):
			for i in range(list["the_first_music_in_the_first_played_sessions"].size()):
				var musicPath = list["the_first_music_in_the_first_played_sessions"][i]
				list["the_first_music_in_the_first_played_sessions"][i] = path.path_join(musicPath)
		miscData = funcs.merge_dicts(miscData, list)
	
	list = filesystem.readJson(path.path_join("/sounds.json"))
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
			
	list = filesystem.readJson(path.path_join("/music.json"))
	if list:
		for music in list:
			musicList.append(loadResource(path.path_join(music)))
			
	list = filesystem.readJson(path.path_join("/ambient.json"))
	if list:
		for ambient in list:
			ambientList.append(loadResource(path.path_join(ambient)))

	list = filesystem.readJson(path.path_join("/blocks.json"))
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
