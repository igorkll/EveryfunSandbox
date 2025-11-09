extends Node

var characters = [preload("res://scripts/classes/player.gd")]

func spawn(character):
	game.characters.add_child(character)

func loadCharacters():
	var player = characters[0].new()
	spawn(player)
	game.player = player
	game.camera = player.camera
