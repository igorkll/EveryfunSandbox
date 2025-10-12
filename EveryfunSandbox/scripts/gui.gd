extends Node

var Continue_game
var audio_Master

func _attachSlider(valuePath, sliderName, range, callback=null):
	var startValue = funcs.getNestedValue(game.settings, valuePath)
	var slider = game.mainNode.find_child(sliderName, true, false)
	slider.min_value = range[0]
	slider.max_value = range[1]
	slider.value = startValue * range[2]
	slider.value_changed.connect(func(value):
		value /= range[2]
		funcs.setNestedValue(game.settings, valuePath, value)
		game.saveSettings()
		if callback != null:
			callback.call(sliderName, value, false)
	)
	callback.call(sliderName, startValue, true)
	
	var resetButton = game.mainNode.find_child(sliderName + "_reset", true, false)
	resetButton.pressed.connect(func():
		slider.value = funcs.getNestedValue(game.defaultSettings, valuePath) * range[2]
		if callback != null:
			callback.call(sliderName, slider.value / range[2], false)
	)

func _audioSlider(sliderName, value, force):
	var label = game.mainNode.find_child(sliderName + "_label", true, false)
	label.text = str(roundi(value * 100)) + "%"
	if not force:
		game.applyAudioSettings()
		
func _attachButton(button, callback):
	var buttonObj = game.mainNode.find_child(button, true, false)
	buttonObj.pressed.connect(callback)
	return buttonObj
	
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
	
	_attachSlider("audio.volume.Master", "ui_audio_Master", [0, 100, 50], _audioSlider)
	_attachSlider("audio.volume.Music", "ui_audio_Music", [0, 100, 50], _audioSlider)
	_attachSlider("audio.volume.Ambient", "ui_audio_Ambient", [0, 100, 50], _audioSlider)
	_attachSlider("audio.volume.Effects", "ui_audio_Effects", [0, 100, 50], _audioSlider)
	
	_attachOption("graphic.quality", "ui_graphic_quality", game.setGraphicQuality)
	_attachOption("graphic.distance", "ui_graphic_distance", game.setRenderDistance)
	
	_attachOption("graphic.window", "ui_window_mode", game.setWindowMode)
	_attachToggleOption("graphic.hdr", "ui_graphic_hdr", game.setHdrState)

func _process(delta):
	Continue_game.disabled = not saves.isWorldFullLoaded()

func _Continue_game_pressed():
	menu.switchUI(1)
	
func _Exit_pressed():
	game.exit()
	
func _Save_pressed():
	saves.save()
