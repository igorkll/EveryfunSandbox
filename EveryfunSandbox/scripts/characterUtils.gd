extends Node

var characterClasses

func updateCharacterList():
	characterClasses = [preload("res://scripts/classes/player.gd")]

func spawn(characterId, position):
	var character = 0
	saves.currentWorldData.characters.append([])
	game.characters.add_child(character)
	return character

func loadCharacters():
	var player = character_player.new()
	spawn(player)
	game.player = player
