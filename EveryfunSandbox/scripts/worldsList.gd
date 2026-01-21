extends Node

var worldCardBase = preload("res://gui/worldCard/worldCard.tscn")
var defaultWorldName = "default world"

# ------------------------------------- world list

var ui_worlds_list

func worldRename(worldName):
	if game.settings.data.selectedWorld == worldName:
		modalUI.messageModal("error", "You can't rename the world you're in.")
	else:
		pass
	
func worldDelete(worldName):
	if game.settings.data.selectedWorld == worldName:
		modalUI.messageModal("error", "you can't delete the world you're in.")
	else:
		saves.delete(worldName)
		updateWorldsList()
	
func worldLoad(worldName):
	if game.settings.data.selectedWorld == worldName:
		modalUI.messageModal("error", "you are already in this world")
	else:
		changeWorld(worldName)

func addWorldToList(worldName):
	var worldCard = worldCardBase.instantiate()
	worldCard.find_child("worldName", true, false).text = worldName
	
	if worldName == game.settings.data.selectedWorld:
		var stylebox = worldCard.get_theme_stylebox("panel", "Panel")
		stylebox.bg_color = Color(1, 0, 0)
		worldCard.add_theme_stylebox_override("panel", stylebox)
	
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

func generateWorldName():
	return funcs.random_name(randi_range(consts.min_random_world_name_len, consts.max_random_world_name_len))

func _ready():
	defaultWorldName = generateWorldName()
	
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
	, generateWorldName())
