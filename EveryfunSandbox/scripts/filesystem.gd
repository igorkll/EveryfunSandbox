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

func isFile(path):
	game.logCall("filesystem.isFile", path)
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	var result = dir.file_exists(spath[1])
	game.logCallResult("filesystem.isFile", result)
	return result

func readFile(path):
	return FileAccess.get_file_as_string(path)
	
func writeFile(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
	file.close()
	
func readFileBytes(path):
	return FileAccess.get_file_as_bytes(path)
	
func writeFileBytes(path, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(data)
	file.close()

func readJson(path):
	return JSON.parse_string(readFile(path))
	
func writeJson(path, data):
	writeFile(path, JSON.stringify(data))
	
func readObj(path):
	return bytes_to_var(readFileBytes(path))
	
func writeObj(path, data):
	writeFileBytes(path, var_to_bytes(data))
