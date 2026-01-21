extends Node

var worldCardBase = preload("res://gui/worldCard/worldCard.tscn")
var defaultWorldName = "default world"

# ------------------------------------- world list

var ui_worlds_list

func worldRename(worldName):
	pass
	
func worldDelete(worldName):
	pass
	
func worldLoad(worldName):
	changeWorld(worldName)

func addWorldToList(worldName):
	var worldCard = worldCardBase.instantiate()
	worldCard.find_child("worldName", true, false).text = worldName
	
	if worldName == game.settings.data.selectedWorld:
		pass
	
	ui_worlds_list.add_child(worldCard)
	funcs.ui_button_callback(worldCard, "worldRename", worldRename.bind(worldName))
	funcs.ui_button_callback(worldCard, "worldDelete", worldDelete.bind(worldName))
	funcs.ui_button_callback(worldCard, "worldLoad", worldLoad.bind(worldName))

func updateWorldsList():
	for child in ui_worlds_list.get_children():
		child.queue_free()
		
	var worldList = saves.list()
	if game.settings.data.selectedWorld in worldList:
		addWorldToList(game.settings.data.selectedWorld)
	for worldName in worldList:
		if game.settings.data.selectedWorld != worldName:
			addWorldToList(worldName)
			
# -------------------------------------

func loadSelectedWorld():
	if saves.exists(game.settings.data.selectedWorld):
		saves.open(game.settings.data.selectedWorld)
	else:
		saves.create(game.settings.data.selectedWorld)

func _changeWorld(worldName):	
	game.settings.data.selectedWorld = worldName
	game.saveSettings()
	
	loadSelectedWorld()
	updateWorldsList()

func changeWorld(worldName):
	saves.save(_changeWorld.bind(worldName))

func _ready():
	ui_worlds_list = game.mainNode.find_child("ui_worlds_list", true, false)
	gui._attachButton("ui_worlds_new", _worlds_new)
	
	if game.settings.data.selectedWorld == null:
		game.settings.data.selectedWorld = defaultWorldName
		game.saveSettings()
	
	loadSelectedWorld()
	updateWorldsList()

func _worlds_new():
	modalUI.inputModal("world name", func(worldName):
		if worldName:
			if saves.exists(worldName):
				modalUI.messageModal("error", "a world with that name already exists")
			else:
				changeWorld(worldName)
	, funcs.random_name(randi_range(consts.min_random_world_name_len, consts.max_random_world_name_len)))
