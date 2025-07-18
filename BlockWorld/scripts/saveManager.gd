extends Node

static var node_root
static var node_main

func _ready():
	node_root = get_tree().root
	node_main = node_root.get_node("Main")


static var save_name
static var save_dir

static func getSavePath(name):
	return "user://saves/" + name

static func loadOrCreate(name):
	save_name = name
	save_dir = getSavePath(save_name)
	DirAccess.make_dir_recursive_absolute(save_dir)

static func save():
	var file = FileAccess.open(save_dir + "/dynamicBlocks.json", FileAccess.WRITE)
	if file:
		var dynamicBlocks = {
			"AS": true
		}
		file.store_string(JSON.stringify(dynamicBlocks))
		file.close()
