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
			"Master": 1,
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
	},
	"game": {
		"autoSaveInterval": 60
	},
	"graphic": {
		"window": 0,
		"vsync": 1,
		"quality": 0,
		"distance": 0,
		"hdr": true,
		"smoothing": true
	}
}

var soundList = {}
var musicList = []
var ambientList = []
var blockList = []
var blockIDs = {}

var graphicSettingsPresets = [
	{
		"shadow_quality": 512,
		"shadow_distance": 32,
		"sdfgi": false,
		"ssao": false,
		"ssil": false,
		"normals": false,
		"bias": 0.1,
		"normalBias": 2.0
	},
	{
		"shadow_quality": 2048,
		"shadow_distance": 64,
		"sdfgi": false,
		"ssao": false,
		"ssil": false,
		"normals": false,
		"bias": 0.1,
		"normalBias": 2.0
	},
	{
		"shadow_quality": 4096,
		"shadow_distance": 96,
		"sdfgi": false,
		"ssao": false,
		"ssil": false,
		"normals": true,
		"bias": 0.05,
		"normalBias": 5.0
	},
	{
		"shadow_quality": 16384,
		"shadow_distance": 256,
		"sdfgi": false,
		"ssao": true,
		"ssil": true,
		"normals": true,
		"bias": 0.01,
		"normalBias": 10.0
	}
]

var distanceSettingsPresets = [
	{
		"distance": 64,
		"lodDistance": 32
	},
	{
		"distance": 256,
		"lodDistance": 64
	},
	{
		"distance": 512,
		"lodDistance": 128
	},
	{
		"distance": 1024,
		"lodDistance": 128
	},
	{
		"distance": 2048,
		"lodDistance": 128
	}
]

var _blockMaterials = []

var view_distance
var lod_distance
func setRenderDistance(index):
	var distanceSettingsPreset = distanceSettingsPresets[index]
	var voxelViewer = mainNode.find_child("VoxelViewer", true, false)
	
	voxelViewer.view_distance = distanceSettingsPreset.distance
	view_distance = distanceSettingsPreset.distance
	lod_distance = distanceSettingsPreset.lodDistance
	
func updateShaderParameters(quality):
	var graphicSettingsPreset = graphicSettingsPresets[quality]
	for _material in _blockMaterials:
		_material.set_shader_parameter("use_normals", graphicSettingsPreset.normals)

func setGraphicQuality(quality):
	var graphicSettingsPreset = graphicSettingsPresets[quality]
	var worldLight = mainNode.find_child("worldLight", true, false)
	var worldEnv = mainNode.find_child("worldEnv", true, false)
	
	RenderingServer.directional_shadow_atlas_set_size(graphicSettingsPreset.shadow_quality, true)
	worldLight.directional_shadow_max_distance = graphicSettingsPreset.shadow_distance
	worldLight.shadow_bias = graphicSettingsPreset.bias
	worldLight.shadow_normal_bias = graphicSettingsPreset.normalBias
	worldEnv.environment.set_sdfgi_enabled(graphicSettingsPreset.sdfgi)
	worldEnv.environment.set_ssao_enabled(graphicSettingsPreset.ssao)
	worldEnv.environment.set_ssil_enabled(graphicSettingsPreset.ssil)
	
	updateShaderParameters(quality)

func setHdrState(hdr):
	get_tree().root.set_use_hdr_2d(hdr)
	
func setWindowMode(mode):
	if mode == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif mode == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			
func setVSyncMode(vsync):
	DisplayServer.window_set_vsync_mode(vsync, 0)
	
func setSmoothingState(smoothing):
	get_tree().root.use_taa = smoothing

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
		mainNode.add_child(audioPlayer)

	audioPlayer.play()
	audioPlayer.connect("finished", Callable(audioPlayer, "queue_free"))
	
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
	defaultSettings.gui.scale = (resolution.y / 1080) * consts.default_scale_on_1080

func loadSettings():
	settings = {}
	if filesystem.isFile(consts.settings_path):
		settings = filesystem.readJson(consts.settings_path)
	defaultSettingsInit()
	settings = funcs.merge_dicts(settings, defaultSettings)
	settings.statistics.game_session_counter = settings.statistics.game_session_counter + 1;
	
	applyAudioSettings()
	setGraphicQuality(settings.graphic.quality)
	setRenderDistance(settings.graphic.distance)
	setHdrState(settings.graphic.hdr)
	setWindowMode(settings.graphic.window)
	setVSyncMode(settings.graphic.vsync)
	setSmoothingState(settings.graphic.smoothing)

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

func getBlockDefaultRotation(globalCameraBasisZ: Vector3) -> int:
	var dir = -globalCameraBasisZ
	var vertical_threshold = 0.8
	
	var angle = atan2(dir.z, dir.x)
	var rotation_index = int(round(angle / (PI / 2)) + 2) % 4
	
	var result = rotation_index
	if dir.y < -vertical_threshold:
		result += 4
	elif dir.y > vertical_threshold:
		result += 8
	return result

func exit():
	if saves.isWorldFullLoaded():
		saves.save(func():
			get_tree().quit()
		)
	else:
		get_tree().quit()

# ------------------------------------------------- backend

var _shader = preload("res://shaders/blocks.gdshader")

# map size: x y
# texture pos: x- x+ y- y+ z- z+
var _textureModes = {
	"DIFFERENT_SIDES": [
		Vector2i(3, 3),
		
		Vector2i(0, 1),
		Vector2i(2, 1),
		Vector2i(0, 0),
		Vector2i(1, 1),
		Vector2i(1, 2),
		Vector2i(1, 0)
	],
	"UNIFORM": [
		Vector2i(1, 1),
		
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0)
	],
	"UNIFORM_TOP_BOTTOM": [
		Vector2i(1, 3),
		
		Vector2i(0, 1),
		Vector2i(0, 1),
		Vector2i(0, 2),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 1)
	],
	"UNIFORM_SIDE": [
		Vector2i(2, 1),
		
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0),
		Vector2i(0, 0)
	],
	"UNIFORM_SIDE_TOP_BOTTOM": [
		Vector2i(2, 3),
		
		Vector2i(0, 1),
		Vector2i(1, 1),
		Vector2i(0, 2),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 1)
	],
	"UNIFORM_TOP": [
		Vector2i(1, 2),
		
		Vector2i(0, 1),
		Vector2i(0, 1),
		Vector2i(0, 1),
		Vector2i(0, 0),
		Vector2i(0, 1),
		Vector2i(0, 1)
	]
}

var rotationModes = {
	"NONE": [
	],
	"360": [
		{y=1, r = Vector3i(0, -90, 0), d = Vector3i(0, 0, 1), u = Vector3i(0, 1, 0)},
		{y=2, r = Vector3i(0, -90 * 2, 0), d = Vector3i(-1, 0, 0), u = Vector3i(0, 1, 0)},
		{y=3, r = Vector3i(0, -90 * 3, 0), d = Vector3i(0, 0, -1), u = Vector3i(0, 1, 0)}
	],
	"360V": [
		{y=1, r = Vector3i(0, -90, 0), d = Vector3i(0, 0, 1), u = Vector3i(0, 1, 0)},
		{y=2, r = Vector3i(0, -90 * 2, 0), d = Vector3i(-1, 0, 0), u = Vector3i(0, 1, 0)},
		{y=3, r = Vector3i(0, -90 * 3, 0), d = Vector3i(0, 0, -1), u = Vector3i(0, 1, 0)},
		
		{y=0, r = Vector3i(0, 0, 90), d = Vector3i(0, 1, 0), u = Vector3i(-1, 0, 0)},
		{y=1, r = Vector3i(0, -90, 90), d = Vector3i(0, 1, 0), u = Vector3i(0, 0, -1)},
		{y=2, r = Vector3i(0, -90 * 2, 90), d = Vector3i(0, 1, 0), u = Vector3i(1, 0, 0)},
		{y=3, r = Vector3i(0, -90 * 3, 90), d = Vector3i(0, 1, 0), u = Vector3i(0, 0, 1)},
		
		{y=0, r = Vector3i(0, 0, -90), d = Vector3i(0, -1, 0), u = Vector3i(-1, 0, 0)},
		{y=1, r = Vector3i(0, -90, -90), d = Vector3i(0, -1, 0), u = Vector3i(0, 0, -1)},
		{y=2, r = Vector3i(0, -90 * 2, -90), d = Vector3i(0, -1, 0), u = Vector3i(1, 0, 0)},
		{y=3, r = Vector3i(0, -90 * 3, -90), d = Vector3i(0, -1, 0), u = Vector3i(0, 0, 1)}
	]
}

func _ready():
	mainNode = get_node("/root/main")
	player = get_node("/root/main/player")
	camera = get_node("/root/main/player/camera")
	gameMessagesContainer = mainNode.find_child("gameMessages", true, false)
	
	loadSettings()
	saveSettings() # update session counter
	
	_addFolder("res://game/main")
	_addFolder("res://game/test")
	
	blockLibrary = _getLibrary()
	_initMusic()
	_initAmbient()
	_initGui()
	
	updateShaderParameters(settings.graphic.quality)

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

var soundsTypes = [
	"sound_walking",
	"sound_jump",
	"sound_headbutt",
	"sound_place",
	"sound_destroy",
	"sound_hit"
]

func _processForks(list):
	var lastNonFork
	var forks = []
	
	for item in list.duplicate():
		if item.has("fork") && item.fork:
			var fork = funcs.merge_dicts(item, lastNonFork)
			fork.erase("fork")
			forks.append(fork)
			list.erase(item)
		else:
			lastNonFork = item
	
	for item in forks:
		list.append(item)
		
		
func _readJson(path):
	if not filesystem.isFile(path):
		return
	return filesystem.readJson(path)

func _checkVariants(blockVariants, item):
	item.currentVariant = 0
	item.variantsList = [item]
	
	if item.has("variants"):
		var currentVariant = 1
		for variant in item["variants"]:
			var variantItem = funcs.merge_dicts(variant, item)
			variantItem.variantsList = item.variantsList
			variantItem.currentVariant = currentVariant
			item.variantsList.append(variantItem)
			blockVariants.append(variantItem)
			currentVariant += 1

func _addFolder(path):
	var list = _readJson(path.path_join("/misc.json"))
	if list:
		if list.has("the_first_music_in_the_first_played_sessions"):
			for i in range(list["the_first_music_in_the_first_played_sessions"].size()):
				var musicPath = list["the_first_music_in_the_first_played_sessions"][i]
				list["the_first_music_in_the_first_played_sessions"][i] = path.path_join(musicPath)
		miscData = funcs.merge_dicts(miscData, list)
	
	list = _readJson(path.path_join("/sounds.json"))
	if list:
		_processForks(list)
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
			
	list = _readJson(path.path_join("/music.json"))
	if list:
		for music in list:
			musicList.append(loadResource(path.path_join(music)))
			
	list = _readJson(path.path_join("/ambient.json"))
	if list:
		for ambient in list:
			ambientList.append(loadResource(path.path_join(ambient)))

	list = _readJson(path.path_join("/blocks.json"))
	if list:
		_processForks(list)
		
		var blockVariants = []
		var rotatedBlocks = []
		for item in list:
			if item.has("sound"):
				for soundkey in soundsTypes:
					if not item.has(soundkey):
						item[soundkey] = item.sound
						
			if item.has("sound_placeDestroy"):
				item.sound_place = item.sound_placeDestroy
				item.sound_destroy = item.sound_placeDestroy
			
			if item.has("texture"):
				item.texture = loadResource(path.path_join(item.texture))
				
			if item.has("material"):
				item.material = loadResource(path.path_join(item.material))
			
			if item.has("name"):
				blockIDs[item.name] = blockList.size()
				
			if item.has("script"):
				item.script = path.path_join(item.script)
				
			item.currentRotation = 0
			item.rotated = [item]
			
			if item.has("rotationMode"):
				var rotationMode = rotationModes[item.rotationMode]
				var currentRotation = 1
				for rotation in rotationMode:
					var rotated = item.duplicate(false)
					rotated.rotated = item.rotated
					rotated.currentRotation = currentRotation
					rotated.rotation = rotation
					rotatedBlocks.append(rotated)
					item.rotated.append(rotated)
					currentRotation += 1
			
			item.id = blockList.size()
			item.baseId = item.id
			_checkVariants(blockVariants, item)
			blockList.append(item)
			
		for rotatedBlock in rotatedBlocks:
			rotatedBlock.id = blockList.size()
			_checkVariants(blockVariants, rotatedBlock)
			blockList.append(rotatedBlock)
			
		for blockVariant in blockVariants:
			blockVariant.id = blockList.size()
			blockList.append(blockVariant)
			
var _defaultMaterialTexture = preload("res://textures/materialTexture.png")

func _getLibrary():
	var library = VoxelBlockyLibrary.new()
	
	for block in blockList:
		var blockModel
		if block.has("texture"):
			var material = ShaderMaterial.new()
			material.shader = _shader
			
			var materialTexture = block.get("material", _defaultMaterialTexture)
			if block.get("material_no_filter", false):
				material.set_shader_parameter("material_texture_no_filter", materialTexture)
				material.set_shader_parameter("no_material_filter", true)
			else:
				material.set_shader_parameter("material_texture", materialTexture)
				material.set_shader_parameter("no_material_filter", false)
				
			if block.get("texture_no_filter", false):
				material.set_shader_parameter("dif_texture_no_filter", block.texture)
				material.set_shader_parameter("no_filter", true)
			else:
				material.set_shader_parameter("dif_texture", block.texture)
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
			
			_blockMaterials.append(material)
		else:
			blockModel = VoxelBlockyModelEmpty.new()
		
		library.add_model(blockModel)
	
	return library
