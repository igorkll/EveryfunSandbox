extends Node

var characterClasses

func updateCharacterList():
	characterClasses = {
		player = preload("res://scripts/classes/player.gd")
	}

func spawn(characterName: String, position: Vector3):
	var id = funcs.getNullIndex(saves.currentWorldData.characters)
	funcs.arraySet(saves.currentWorldData.characters, id, [characterName, {
		_character_position = position
	}])
	return loadCharacter(id)

func findSpawnPosition():
	return Vector3(0, 15, 0)

func loadCharacter(id):
	var characterInfo = saves.currentWorldData.characters[id]
	
	var character = characterClasses[characterInfo[0]].new()
	character.id = id
	character.storageData = characterInfo[1]
	character.loadCharacterStorageData()
	
	saves.currentWorldRuntimeData.characters[character.id] = character
	game.characters.add_child(character)
	return character

func unloadCharacter(character):
	saves.currentWorldRuntimeData.characters.erase(character.id)
	character.updateCharacterStorageData()
	saves.saveCharacterId(character)
	character.queue_free()

func destroyCharacter(character):
	saves.currentWorldRuntimeData.characters.erase(character.id)
	funcs.arraySet(saves.currentWorldData.characters, character.id, null)
	funcs.deleteAllNullsOnEnd(saves.currentWorldData.characters)	
	character.queue_free()
