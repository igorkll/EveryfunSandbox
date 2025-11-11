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
	var characterInfo = saves.currentWorldData.characters[id]
	
	var character = characterClasses[characterInfo[0]].new()
	character.storageData = characterInfo[1]
	saves.currentWorldRuntimeData.characters[character.id] = character
	game.characters.add_child(character)
	return character

func unloadCharacter(character):
	saves.currentWorldRuntimeData.characters.erase(character.id)
	game.characters.remove_child(character)

func destroyCharacter(character):
	pass
