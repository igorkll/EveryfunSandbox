extends Node

var characterClasses

func updateCharacterList():
	characterClasses = [preload("res://scripts/classes/player.gd")]

func spawn(characterId, position):
	var character = characterClasses[characterId].new()
	saves.currentWorldData.characters.append([])
	game.characters.add_child(character)
	return character

func findSpawnPosition():
	return Vector3(0, 15, 0)
