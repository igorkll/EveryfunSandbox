extends Node

var _availableRoots = ["user://", "res://"]

func splitGodotPath(path):
	var root
	var base

	for checkRoot in _availableRoots:
		if path.begins_with(checkRoot):
			root = checkRoot
			base = path.substr(checkRoot.length())
			
	var result = [root, base]
	game.logCall("filesystem.splitGodotPath", result, result)
	return result

func makeDirectory(path):
	game.logCall("filesystem.makeDirectory", null, path)
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[1])
	dir.make_dir_recursive(spath[2])
