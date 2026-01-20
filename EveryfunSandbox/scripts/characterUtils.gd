extends Node

var characterClasses

func updateCharacterList():
	characterClasses = {
		player = preload("res://scripts/classes/player.gd")
	}
	
func updateCharacterDataInSave(character):
	funcs.arraySet(saves.currentWorldData.characters, character.id, [
		character.name,
		character.storageData,
		character.position,
		character.velocity,
		character.quaternion
	])

func spawn(characterName: String, position: Vector3):
	var id = funcs.getNullIndex(saves.currentWorldData.characters)
	funcs.arraySet(saves.currentWorldData.characters, id, [
		characterName,
		{},
		position,
		Vector3(0, 0, 0),
		Quaternion()
	])
	return loadCharacter(id)

func findSpawnPosition():
	return Vector3(0, 50, 0)

func loadCharacter(id):
	var characterInfo = saves.currentWorldData.characters[id]
	
	var character = characterClasses[characterInfo[0]].new()
	character.id = id
	character.name = characterInfo[0]
	character.storageData = characterInfo[1]
	character.position = characterInfo[2]
	character.velocity = characterInfo[3]
	character.quaternion = characterInfo[4]
	
	saves.currentWorldRuntimeData.characters[character.id] = character
	game.characters.add_child(character)
	return character

func unloadCharacter(character):
	saves.currentWorldRuntimeData.characters.erase(character.id)
	updateCharacterDataInSave(character)
	saves.saveCharacterId(character)
	character.queue_free()

func destroyCharacter(character):
	saves.currentWorldRuntimeData.characters.erase(character.id)
	funcs.arraySet(saves.currentWorldData.characters, character.id, null)
	funcs.deleteAllNullsOnEnd(saves.currentWorldData.characters)	
	character.queue_free()

func createHuman() -> Humanizer:
	var config = HumanConfig.new()
	config.targets['gender'] = 0.0
	config.init_macros()
	config.eye_color = Color.GREEN
	config.hair_color = Color.PURPLE
	config.eyebrow_color = Color("550055")
	config.rig = "game_engine-RETARGETED"
	config.add_equipment(HumanizerEquipment.new("DefaultBody"))
	config.add_equipment(HumanizerEquipment.new("Pants-SkinnyJeans"))
	config.add_equipment(HumanizerEquipment.new("Shirt-MakeHumanTShirt"))
	config.add_equipment(HumanizerEquipment.new("Shoes-02"))
	config.add_equipment(HumanizerEquipment.new("RightEye-LowPolyEyeball"))
	config.add_equipment(HumanizerEquipment.new("LeftEye-LowPolyEyeball"))
	config.add_equipment(HumanizerEquipment.new("RightEyebrow-002"))
	config.add_equipment(HumanizerEquipment.new("LeftEyebrow-002"))
	config.add_equipment(HumanizerEquipment.new("RightEyelash"))
	config.add_equipment(HumanizerEquipment.new("LeftEyelash"))
	
	var hum := Humanizer.new()
	hum.load_config_async(config)
	return hum
