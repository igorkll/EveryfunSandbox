extends Node

static func save(name):
	var file = FileAccess.open("user://Saves/" + name + "/dynamicBlocks.json", FileAccess.WRITE)
	if file:
		var dynamicBlocks = {}
		file.store_string(JSON.stringify(dynamicBlocks))
		file.close()
