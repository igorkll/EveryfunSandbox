extends Node

static func getSavePath(name):
	return "user://saves/" + name

static func save(name):
	var saveDir = getSavePath(name)
	DirAccess.make_dir_recursive_absolute(saveDir)
	var file = FileAccess.open(saveDir + "/dynamicBlocks.json", FileAccess.WRITE)
	if file:
		var dynamicBlocks = {
			"AS": true
		}
		file.store_string(JSON.stringify(dynamicBlocks))
		file.close()
