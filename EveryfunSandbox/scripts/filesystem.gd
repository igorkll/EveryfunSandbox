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
	
func makeDirectoryForFile(path):
	path = path.get_base_dir()
	if not isDirectory(path):
		var spath = splitGodotPath(path)
		var dir = DirAccess.open(spath[0])
		dir.make_dir_recursive(spath[1])

func isDirectory(path) -> bool:
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	return dir.dir_exists(spath[1])

func isFile(path) -> bool:
	var spath = splitGodotPath(path)
	var dir = DirAccess.open(spath[0])
	return dir.file_exists(spath[1])

func readFile(path):
	return FileAccess.get_file_as_string(path)
	
func writeFile(path, data):
	makeDirectoryForFile(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data)
	file.close()
	
func readFileBytes(path):
	return FileAccess.get_file_as_bytes(path)
	
func writeFileBytes(path, data):
	makeDirectoryForFile(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(data)
	file.close()

func readJson(path):
	return JSON.parse_string(readFile(path))
	
func checkExistsAndReadJson(path):
	if not isFile(path):
		return
	return readJson(path)
	
func writeJson(path, data):
	writeFile(path, JSON.stringify(data))
	
func readObj(path):
	return bytes_to_var(readFileBytes(path))
	
func writeObj(path, data):
	writeFileBytes(path, var_to_bytes(data))

func list(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var folder_list = []
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				folder_list.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		
		return folder_list
	else:
		return []
		
func remove(path) -> bool:
	var dir := DirAccess.open("res://")
	if dir:
		if dir.file_exists(path):
			var result = dir.remove(path)
			return result == OK
	return false
