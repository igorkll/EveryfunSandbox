extends Node

var _Continue_game
var _Save_game
var audio_Master

func setNestedValue(path, value):
	var tbl = game.settings
	if path.begins_with("&"):
		tbl = saves.currentWorldData
		path = path.substr(1)
	funcs.setNestedValue(tbl, path, value)
	
func getNestedValue(path, default=false):
	var tbl
	if path.begins_with("&"):
		if default:
			tbl = saves.defaultWorldData
		else:
			tbl = saves.currentWorldData
		path = path.substr(1)
	elif default:
		tbl = game.defaultSettings
	else:
		tbl = game.settings
	return funcs.getNestedValue(tbl, path)

func _attachSlider(valuePath, sliderName, range, callback=null):
	var startValue = getNestedValue(valuePath)
	var slider = game.mainNode.find_child(sliderName, true, false)
	slider.min_value = range[0] * 100
	slider.max_value = range[1] * 100
	slider.value = startValue * 100
	slider.value_changed.connect(func(value):
		value /= 100
		setNestedValue(valuePath, value)
		game.saveSettings()
		if callback != null:
			callback.call(sliderName, value, false, false)
	)
	slider.drag_ended.connect(func(value):
		if callback != null:
			callback.call(sliderName, slider.value / 100, false, true)
	)
	callback.call(sliderName, startValue, true, false)
	
	var resetButton = game.mainNode.find_child(sliderName + "_reset", true, false)
	resetButton.pressed.connect(func():
		slider.value = getNestedValue(valuePath, true) * 100
		if callback != null:
			callback.call(sliderName, slider.value / 100, false, true)
	)

func _updateSlider(sliderName, value, force, released):
	var label = game.mainNode.find_child(sliderName + "_label", true, false)
	if sliderName == "ui_game_autoSaveInterval":
		label.text = str(roundi(value)) + " seconds"
	else:
		label.text = str(roundi(value * 100)) + "%"
	
	if sliderName == "ui_gui_uiScale":
		if released:
			game.setScale(value)
	elif not force:
		if sliderName.begins_with("ui_audio_"):
			game.applyAudioSettings()
		
func _attachButton(button, callback):
	var buttonObj = game.mainNode.find_child(button, true, false)
	buttonObj.pressed.connect(callback)
	return buttonObj
	
func _attachButtons(button, callback):
	var buttonsList = game.mainNode.find_children(button, "Button", true, false)
	for buttonObj in buttonsList:
		buttonObj.pressed.connect(callback)
	
func _attachOption(valuePath, optionName, callback):
	var startValue = getNestedValue(valuePath)
	var optionButton = game.mainNode.find_child(optionName, true, false)
	optionButton.selected = startValue
	optionButton.item_selected.connect(func(value):
		setNestedValue(valuePath, value)
		game.saveSettings()
		if callback != null:
			callback.call(value)
	)

func _updateToggleOption(valuePath, optionName):
	var optionButton = game.mainNode.find_child(optionName, true, false)
	optionButton.button_pressed = getNestedValue(valuePath)

func _attachToggleOption(valuePath, optionName, callback):
	var startValue = getNestedValue(valuePath)
	var optionButton = game.mainNode.find_child(optionName, true, false)
	optionButton.button_pressed = startValue
	optionButton.toggled.connect(func(value):
		setNestedValue(valuePath, value)
		game.saveSettings()
		if callback != null:
			callback.call(value)
	)

var ui_debug_panel
var ui_debug_fps
var ui_debug_position

func _ready():
	_Continue_game = _attachButton("ui_Continue_game", _Continue_game_pressed)
	_attachButton("ui_Exit", _Exit_pressed)
	_Save_game = _attachButton("ui_Save", _Save_pressed)
	_attachButton("ui_Credits", _Credits_pressed)
	_attachButton("ui_License", _License_pressed)
	_attachButtons("esc_done", _EscDone_pressed)
	
	_attachSlider("game.autoSaveInterval", "ui_game_autoSaveInterval", [10, 60 * 30], _updateSlider)
	_attachToggleOption("game.muteOnMenu", "ui_game_muteOnMenu", func(unused):
		game.setMuteAllExceptMusic(game.muteAllExceptMusic))
	
	_attachSlider("gui.scale", "ui_gui_uiScale", [0.25, 4], _updateSlider)
	_attachToggleOption("gui.useNativeFileDialog", "ui_gui_useNativeFileDialog", null)
	_attachToggleOption("gui.showSaveLabel", "ui_gui_showSaveLabel", null)
	
	_attachSlider("audio.volume.Master", "ui_audio_Master", [0, 2], _updateSlider)
	_attachSlider("audio.volume.Music", "ui_audio_Music", [0, 2], _updateSlider)
	_attachSlider("audio.volume.Ambient", "ui_audio_Ambient", [0, 2], _updateSlider)
	_attachSlider("audio.volume.Effects", "ui_audio_Effects", [0, 2], _updateSlider)
	_attachSlider("audio.volume.Interactive blocks", "ui_audio_Interactive", [0, 2], _updateSlider)
	
	_attachOption("graphic.quality", "ui_graphic_quality", game.setGraphicQuality)
	_attachOption("graphic.distance", "ui_graphic_distance", game.setRenderDistance)
	_attachOption("graphic.window", "ui_window_mode", game.setWindowMode)
	_attachOption("graphic.vsync", "ui_vsync_mode", game.setVSyncMode)
	
	_attachSlider("control.mouse.sensitivity", "ui_control_mouse_sensitivity", [0, 2], _updateSlider)
	_attachSlider("control.joystick.sensitivity", "ui_control_joystick_sensitivity", [0, 2], _updateSlider)
	_attachSlider("control.joystick.deadzone", "ui_control_joystick_deadzone", [0, 0.5], _updateSlider)
	
	signals.connect("world_open", _on_world_open)
	
	ui_debug_panel = game.mainNode.find_child("ui_debug_panel", true, false)
	ui_debug_fps = game.mainNode.find_child("ui_debug_fps", true, false)
	ui_debug_position = game.mainNode.find_child("ui_debug_position", true, false)

func _process(delta):
	var worldLoaded = saves.isWorldFullLoaded()
	_Continue_game.disabled = not worldLoaded
	_Save_game.disabled = not worldLoaded
	
	if saves.isWorldLoaded():
		ui_debug_panel.visible = saves.currentWorldData.debug.debugInfo
		ui_debug_fps.text = str(Engine.get_frames_per_second())
		ui_debug_position.text = str(funcs.round_to(game.player.position.x, 1)) + " " + str(funcs.round_to(game.player.position.y, 1)) + " " + str(funcs.round_to(game.player.position.z, 1))
	else:
		ui_debug_panel.visible = false

var _worldLoaded = false
func _on_world_open(worldName):
	if _worldLoaded:
		for name in saves.defaultWorldData.debug:
			_updateToggleOption("&debug." + name, "ui_debug_" + name)
	else:
		for name in saves.defaultWorldData.debug:
			_attachToggleOption("&debug." + name, "ui_debug_" + name, null)
	_worldLoaded = true

func _Continue_game_pressed():
	menu.switchUI(1)
	
func _Exit_pressed():
	game.exit()
	
func _Save_pressed():
	saves.save()

func _Credits_pressed():
	menu.showText(filesystem.readFile("res://gui/CREDITS.txt"))
	
func _License_pressed():
	menu.showText(filesystem.readFile("res://gui/LICENSE.txt"))
	
func _EscDone_pressed():
	modalUI.close()
