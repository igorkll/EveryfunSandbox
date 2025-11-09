extends Node

func spawn(character):
	game.characters.add_child(character)

func loadCharacters():
	spawn()
