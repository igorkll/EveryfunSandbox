extends Node

var _availableRoots = ["user://", "res://"]

func splitGodotPath(path):
	game.logCall("filesystem.splitGodotPath", path)
	var root
	var base

	for checkRoot in _availableRoots:
		if path.begins_with(checkRoot):
			root = checkRoot
			base = path.substr(checkRoot.length())
			
	var result = [root, base]
	game.logCallResult("filesystem.splitGodotPath", result)
	return result

func makeDirectory(path):
	game.logCall("filesystem.makeDirectory", path)
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	dir.make_dir_recursive(spath[1])
	game.logCallResult("filesystem.makeDirectory", null)

func isDirectory(path):
	game.logCall("filesystem.isDirectory", path)
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	var result = dir.dir_exists(spath[1])
	game.logCallResult("filesystem.isDirectory", result)
	return result
