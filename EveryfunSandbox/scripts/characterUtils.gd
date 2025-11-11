extends Node

var characterClasses

func updateCharacterList():
	characterClasses = {
		player = preload("res://scripts/classes/player.gd")
	}

func spawn(characterName, position):
	var character = characterClasses[characterName].new()
	saves.currentWorldData.characters.append([])
	saves.currentWorldRuntimeData.characters[character.id] = character
	game.characters.add_child(character)
	return character

func findSpawnPosition():
	return Vector3(0, 15, 0)

func loadCharacter(id):
	var characterInfo = 

func unloadCharacter(character):
	saves.currentWorldRuntimeData.characters.erase(character.id)

func destroyCharacter(character):
	pass
