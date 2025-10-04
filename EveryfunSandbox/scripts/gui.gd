extends Node

var Continue_game
var audio_Master

func _attachSlider(valuePath, sliderName, range, callback=null):
	var defaultValue = funcs.getNestedValue(game.settings, valuePath)
	var slider = game.mainNode.find_child(sliderName, true, false)
	slider.min_value = range[0]
	slider.max_value = range[1]
	slider.value = defaultValue * range[2]
	slider.value_changed.connect(func(value):
		value /= range[2]
		funcs.setNestedValue(game.settings, valuePath, value)
		if callback != null:
			callback.call(sliderName, value, false)
	)
	callback.call(sliderName, slider.value, true)

func _audioSlider(sliderName, value, force):
	var label = game.mainNode.find_child(sliderName + "_label", true, false)
	label.text = str(roundi(value * 100)) + "%"
	if not force:
		game.applyAudioSettings()

func _ready():
	Continue_game = game.mainNode.find_child("ui_Continue_game", true, false)
	Continue_game.pressed.connect(_Continue_game_pressed)
	
	_attachSlider("audio.volume.Master", "ui_audio_Master", [0, 100, 50], _audioSlider)
	_attachSlider("audio.volume.Music", "ui_audio_Music", [0, 100, 50], _audioSlider)
	_attachSlider("audio.volume.Ambient", "ui_audio_Ambient", [0, 100, 50], _audioSlider)
	_attachSlider("audio.volume.Effects", "ui_audio_Effects", [0, 100, 50], _audioSlider)

func _process(delta):
	Continue_game.disabled = not saves.isWorldFullLoaded()

func _Continue_game_pressed():
	menu.switchUI(1)
