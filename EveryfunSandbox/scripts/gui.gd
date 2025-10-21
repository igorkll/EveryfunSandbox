extends Node

var Continue_game
var audio_Master

func _attachSlider(valuePath, sliderName, range, callback=null):
	var startValue = funcs.getNestedValue(game.settings, valuePath)
	var slider = game.mainNode.find_child(sliderName, true, false)
	slider.min_value = range[0] * 100
	slider.max_value = range[1] * 100
	slider.value = startValue * 100
	slider.value_changed.connect(func(value):
		value /= 100
		funcs.setNestedValue(game.settings, valuePath, value)
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
		slider.value = funcs.getNestedValue(game.defaultSettings, valuePath) * 100
		if callback != null:
			callback.call(sliderName, slider.value / 100, false, true)
	)

func _audioSlider(sliderName, value, force, released):
	var label = game.mainNode.find_child(sliderName + "_label", true, false)
	if sliderName == "ui_game_autoSaveInterval":
		label.text = str(roundi(value)) + " seconds"
	else:
		label.text = str(roundi(value * 100)) + "%"
	
	if sliderName == "ui_gui_uiScale":
		if released:
			game.setScale(value)
	elif sliderName.begins_with("ui_audio_") && not force:
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
	var startValue = funcs.getNestedValue(game.settings, valuePath)
	var optionButton = game.mainNode.find_child(optionName, true, false)
	optionButton.selected = startValue
	optionButton.item_selected.connect(func(value):
		funcs.setNestedValue(game.settings, valuePath, value)
		game.saveSettings()
		if callback != null:
			callback.call(value)
	)
	
func _attachToggleOption(valuePath, optionName, callback):
	var startValue = funcs.getNestedValue(game.settings, valuePath)
	var optionButton = game.mainNode.find_child(optionName, true, false)
	optionButton.button_pressed = startValue
	optionButton.toggled.connect(func(value):
		funcs.setNestedValue(game.settings, valuePath, value)
		game.saveSettings()
		if callback != null:
			callback.call(value)
	)

func _ready():
	Continue_game = _attachButton("ui_Continue_game", _Continue_game_pressed)
	_attachButton("ui_Exit", _Exit_pressed)
	_attachButton("ui_Save", _Save_pressed)
	_attachButton("ui_Credits", _Credits_pressed)
	_attachButton("ui_License", _License_pressed)
	_attachButtons("esc_done", _EscDone_pressed)
	
	_attachSlider("game.autoSaveInterval", "ui_game_autoSaveInterval", [10, 60 * 30], _audioSlider)
	_attachToggleOption("game.muteOnMenu", "ui_game_muteOnMenu", null)
	
	_attachSlider("gui.scale", "ui_gui_uiScale", [0.25, 4], _audioSlider)
	_attachToggleOption("gui.useNativeFileDialog", "ui_gui_useNativeFileDialog", null)
	_attachToggleOption("gui.showSaveLabel", "ui_gui_showSaveLabel", null)
	
	_attachSlider("audio.volume.Master", "ui_audio_Master", [0, 2], _audioSlider)
	_attachSlider("audio.volume.Music", "ui_audio_Music", [0, 2], _audioSlider)
	_attachSlider("audio.volume.Ambient", "ui_audio_Ambient", [0, 2], _audioSlider)
	_attachSlider("audio.volume.Effects", "ui_audio_Effects", [0, 2], _audioSlider)
	_attachSlider("audio.volume.Interactive blocks", "ui_audio_Interactive", [0, 2], _audioSlider)
	
	_attachOption("graphic.quality", "ui_graphic_quality", game.setGraphicQuality)
	_attachOption("graphic.distance", "ui_graphic_distance", game.setRenderDistance)
	
	_attachOption("graphic.window", "ui_window_mode", game.setWindowMode)
	_attachOption("graphic.vsync", "ui_vsync_mode", game.setVSyncMode)
	_attachToggleOption("graphic.hdr", "ui_graphic_hdr", game.setHdrState)
	_attachToggleOption("graphic.smoothing", "ui_graphic_smoothing", game.setSmoothingState)

func _process(delta):
	Continue_game.disabled = not saves.isWorldFullLoaded()

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
	menu.switchUI(menu.backTo)
