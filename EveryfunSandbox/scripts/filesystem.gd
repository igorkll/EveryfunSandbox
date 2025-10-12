extends Node

var _availableRoots = ["user://", "res://"]

func splitGodotPath(path):
	var root
	var base

	for checkRoot in _availableRoots:
		if path.begins_with(checkRoot):
			root = checkRoot
			base = path.substr(checkRoot.length())
			
	return [root, base]

func makeDirectory(path):
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	dir.make_dir_recursive(spath[1])

func isDirectory(path):
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	return dir.dir_exists(spath[1])

func isFile(path):
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	return dir.file_exists(spath[1])

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
