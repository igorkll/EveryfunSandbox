extends Node

var sceneTree
var mainNode
var terrain
var objects
var scene
var world
var dynamicBodies
var characters
var player
var camera
var blockLibrary
var settings
var miscData = {}
var muteAllExceptMusic = false
var transparency_material

var allTerrainNodes = []

var defaultSettings = {
	"statistics": {
		"game_session_counter": 0
	},
	"data": {
		"selectedWorld": null
	},
	"audio": {
		"volume": {
			"Master": 1,
			"Music": 0.3,
			"Ambient": 0.2,
			"Interactive blocks": 1,
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
		"scale": 1,
		"useNativeFileDialog": true,
		"showSaveLabel": true
	},
	"game": {
		"autoSaveInterval": 60,
		"muteOnMenu": true
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

var graphicSettingsPresets = [
	{
		"shadow": false,
		"shadow_quality": 512,
		"shadow_distance": 32,
		"sdfgi": false,
		"ssao": false,
		"ssil": false,
		"bias": 0.1,
		"normalBias": 2.0
	},
	{
		"shadow": true,
		"shadow_quality": 2048,
		"shadow_distance": 64,
		"sdfgi": false,
		"ssao": false,
		"ssil": false,
		"bias": 0.1,
		"normalBias": 2.0
	},
	{
		"shadow": true,
		"shadow_quality": 4096,
		"shadow_distance": 96,
		"sdfgi": false,
		"ssao": false,
		"ssil": false,
		"bias": 0.05,
		"normalBias": 5.0
	},
	{
		"shadow": true,
		"shadow_quality": 16384,
		"shadow_distance": 256,
		"sdfgi": false,
		"ssao": true,
		"ssil": true,
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

var view_distance
var lod_distance
func setRenderDistance(index):
	var distanceSettingsPreset = distanceSettingsPresets[index]
	var voxelViewer = mainNode.find_child("VoxelViewer", true, false)
	
	voxelViewer.view_distance = distanceSettingsPreset.distance
	view_distance = distanceSettingsPreset.distance
	lod_distance = distanceSettingsPreset.lodDistance

func getGraphicSettingsPresets(quality=null):
	if quality == null:
		quality = settings.graphic.quality
	return graphicSettingsPresets[quality]
	
func applyLightGraphicSettings(light, quality=null):
	var graphicSettingsPreset = getGraphicSettingsPresets(quality)
	
	light.shadow_enabled = graphicSettingsPreset.shadow
	light.shadow_bias = graphicSettingsPreset.bias
	light.shadow_normal_bias = graphicSettingsPreset.normalBias

func updateGraphicParameters(quality):
	var graphicSettingsPreset = getGraphicSettingsPresets(quality)
		
	for child in allTerrainNodes:
		if child is OmniLight3D || child is SpotLight3D:
			applyLightGraphicSettings(child, quality)

func setGraphicQuality(quality):
	var graphicSettingsPreset = getGraphicSettingsPresets(quality)
	var worldLight = mainNode.find_child("worldLight", true, false)
	var worldEnv = mainNode.find_child("worldEnv", true, false)
	
	RenderingServer.directional_shadow_atlas_set_size(graphicSettingsPreset.shadow_quality, true)
	worldLight.directional_shadow_max_distance = graphicSettingsPreset.shadow_distance
	worldLight.shadow_enabled = graphicSettingsPreset.shadow
	worldLight.shadow_bias = graphicSettingsPreset.bias
	worldLight.shadow_normal_bias = graphicSettingsPreset.normalBias
	worldEnv.environment.set_sdfgi_enabled(graphicSettingsPreset.sdfgi)
	worldEnv.environment.set_ssao_enabled(graphicSettingsPreset.ssao)
	worldEnv.environment.set_ssil_enabled(graphicSettingsPreset.ssil)
	
	updateGraphicParameters(quality)

func setHdrState(hdr):
	sceneTree.root.set_use_hdr_2d(hdr)

var _crosspiece
func setCrosspiece(name):
	if _crosspiece == name:
		return
	_crosspiece = name
	mainNode.find_child("crosspiece", true, false).texture = loadResource(("res://gui/crosspiece").path_join(name + ".png"))
	
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
	sceneTree.root.use_taa = smoothing

func loadResource(resourcePath):
	if resourcePath.begins_with("res://") or resourcePath.begins_with("user://"):
		return load(resourcePath)
	else:
		var extension = resourcePath.get_extension()
		if extension == "mp3":
			return AudioStreamMP3.load_from_file(resourcePath)
		elif extension == "wav":
			return AudioStreamWAV.load_from_file(resourcePath)
		elif extension == "ogg":
			return AudioStreamOggVorbis.load_from_file(resourcePath)
	
func initAudioStream(audioPlayer: AudioStreamPlayer3D, settings=null):
	if settings == null:
		settings = {}
	
	audioPlayer.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	audioPlayer.unit_size = settings.get("unit_size", consts.default_sound_unit_size)
	audioPlayer.max_distance = settings.get("max_distance", consts.default_sound_max_distance)
	audioPlayer.volume_db = settings.get("volume_db", 0)
	audioPlayer.max_db = settings.get("max_db", 3)

func playSound(sound, position: Vector3, parent=null, channel="Effects"):
	var audioPlayer = AudioStreamPlayer3D.new()
	audioPlayer.bus = channel
	audioPlayer.stream = sound.stream
	initAudioStream(audioPlayer, sound)
	
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

func setAudioChannelVolume(bus, multiplier):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(multiplier))
	
func applyAudioSettings():
	for key in settings.audio.volume.keys():
		setAudioChannelVolume(key, settings.audio.volume[key])
		
	var mute = muteAllExceptMusic && game.settings.game.muteOnMenu
	game.setAudioChannelVolume("NotMusic", 0 if mute else 1)
	
func setMuteAllExceptMusic(mute):
	muteAllExceptMusic = mute
	applyAudioSettings()

func defaultSettingsInit():
	var currentScreen = DisplayServer.window_get_current_screen()
	if currentScreen < 0:
		currentScreen = 0
	
	var resolution = DisplayServer.screen_get_size(currentScreen)
	defaultSettings.gui.scale = (resolution.y / 1080.0) * consts.default_scale_on_1080
 
func applySettings():
	applyAudioSettings()
	setGraphicQuality(settings.graphic.quality)
	setRenderDistance(settings.graphic.distance)
	setHdrState(settings.graphic.hdr)
	setWindowMode(settings.graphic.window)
	setVSyncMode(settings.graphic.vsync)
	setSmoothingState(settings.graphic.smoothing)

func loadSettings():
	settings = {}
	if filesystem.isFile(consts.settings_path):
		settings = filesystem.readJson(consts.settings_path)
	defaultSettingsInit()
	settings = funcs.merge_dicts(settings, defaultSettings)
	settings.statistics.game_session_counter = settings.statistics.game_session_counter + 1;
	
	applySettings()

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
	
var gameMessageBase = preload("res://gui/gameMessage.tscn")
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
	sceneTree.root.content_scale_factor = scale
	
func getScale():
	return sceneTree.root.content_scale_factor

func exit():
	if saves.isWorldFullLoaded():
		saves.save(func():
			sceneTree.quit()
		)
	else:
		sceneTree.quit()
	
func requestFile(filters, callback):
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.use_native_dialog = settings.gui.useNativeFileDialog
	for filter in filters:
		dialog.add_filter(filter[0], filter[1])
	add_child(dialog)
	dialog.popup_centered()

	menu.switchUI(2)
	dialog.file_selected.connect(func(path):
		menu.switchUI(1)
		callback.call(path)
	)
	dialog.canceled.connect(func():
		menu.toggleTimeout = 1.0 / 30.0
		menu.switchUI(1)
		callback.call(null)
	)

var _pressedCounter = {}
var _multiplePressTimeout = 200

func is_action_multiple_pressed(actionName, count=2):
	var counter
	if not _pressedCounter.has(actionName):
		counter = [false, 0, -1]
		_pressedCounter[actionName] = counter
	else:
		counter = _pressedCounter[actionName]
	
	var returnState = false
	
	var state = Input.is_action_pressed(actionName)
	if state && !counter[0]:
		var time = Time.get_ticks_msec()
		if counter[2] < 0 || time - counter[2] > _multiplePressTimeout:
			counter[1] = 0
		counter[2] = time
		
		counter[1] += 1
		if counter[1] >= count:
			returnState = true
			counter[1] = 0
	counter[0] = state
	
	return returnState
	
func processForks(list):
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
		
func collisionFromMesh(mesh):
	var collision = CollisionShape3D.new()
	var shape = ConvexPolygonShape3D.new()
	shape.points = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	collision.shape = shape
	return collision

# ------------------------------------------------- backend

func _ready():
	sceneTree = get_tree()
	scene = sceneTree.current_scene
	mainNode = get_node("/root/main")
	objects = get_node("/root/main/objects")
	world = scene.get_world_3d()
	gameMessagesContainer = mainNode.find_child("gameMessages", true, false)
	
	loadSettings()
	saveSettings() # update session counter
	
	_addFolder("res://game/main")
	_addFolder("res://game/test")
	
	blockLibrary = blockUtils.genLibrary()
	_initMusic()
	_initAmbient()
	_initGui()
	
	updateGraphicParameters(settings.graphic.quality)
	setCrosspiece("normal")
	
	sceneTree.quit_on_go_back = false
	sceneTree.auto_accept_quit = false
	sceneTree.root.connect("close_requested", _on_close_requested)
	
func _on_close_requested():
	exit()

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
	var list = filesystem.checkExistsAndReadJson(path.path_join("/misc.json"))
	if list:
		if list.has("the_first_music_in_the_first_played_sessions"):
			for i in range(list["the_first_music_in_the_first_played_sessions"].size()):
				var musicPath = list["the_first_music_in_the_first_played_sessions"][i]
				list["the_first_music_in_the_first_played_sessions"][i] = path.path_join(musicPath)
		miscData = funcs.merge_dicts(miscData, list)
	
	list = filesystem.checkExistsAndReadJson(path.path_join("/sounds.json"))
	if list:
		processForks(list)
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
			
	list = filesystem.checkExistsAndReadJson(path.path_join("/music.json"))
	if list:
		for music in list:
			musicList.append(loadResource(path.path_join(music)))
			
	list = filesystem.checkExistsAndReadJson(path.path_join("/ambient.json"))
	if list:
		for ambient in list:
			ambientList.append(loadResource(path.path_join(ambient)))

	blockUtils.regBlockList(path.path_join("/blocks.json"))
	
	list = filesystem.checkExistsAndReadJson(path.path_join("/blockLists.json"))
	if list:
		for blockList in list:
			blockUtils.regBlockList(path.path_join(blockList))
