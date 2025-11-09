extends Node

var characters = [preload("res://scripts/classes/player.gd")]

func spawn(character):
	game.characters.add_child(character)

func loadCharacters():
	spawn(characters[0].new())
