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
		funcs.setNestedValue(game.settings, valuePath, value / range[2])
		if callback != null:
			callback.call()
	)

func _ready():
	Continue_game = game.mainNode.find_child("ui_Continue_game", true, false)
	Continue_game.pressed.connect(_Continue_game_pressed)
	
	_attachSlider("audio.volume.Master", "ui_audio_Master", [0, 100, 100], game.applyAudioSettings)

func _process(delta):
	Continue_game.disabled = not saves.isWorldFullLoaded()

func _Continue_game_pressed():
	menu.switchUI(1)
