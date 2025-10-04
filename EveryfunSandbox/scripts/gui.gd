extends Node

var Continue_game

func _ready():
	Continue_game = game.mainNode.find_child("ui_Continue_game", true, false)
	Continue_game.pressed.connect(Continue_game_pressed)

func _process(delta):
	Continue_game.disabled = not saves.isWorldFullLoaded()

func Continue_game_pressed():
	menu.switchUI(1)
