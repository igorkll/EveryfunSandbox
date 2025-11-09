extends Node

var character_player = preload("res://scripts/classes/player.gd")

func spawn(character):
	game.characters.add_child(character)

func loadCharacters():
	var player = character_player.new()
	spawn(player)
	game.player = player
