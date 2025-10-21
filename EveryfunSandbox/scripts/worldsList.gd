extends Node

var defaultWorldName = "default world"
var ui_worlds_list

func addWorldToList(worldName):
	pass

func updateWorldsList():
	for child in ui_worlds_list.get_children():
		child.queue_free()
		
	for worldName in saves.list():
		addWorldToList(worldName)

func openDefaultWorld():
	if game.settings.selectedWorld != null:
		if saves.exists(game.settings.selectedWorld):
			saves.open(game.settings.selectedWorld)
		else:
			game.settings.selectedWorld = null
			game.saveSettings()
			openDefaultWorld()
	elif saves.exists(defaultWorldName):
		saves.open(defaultWorldName)
	else:
		saves.create(defaultWorldName)

func _ready():
	ui_worlds_list = game.mainNode.find_child("ui_worlds_list", true, false)
	gui._attachButton("ui_worlds_new", _worlds_new)
	openDefaultWorld()
	updateWorldsList()

func _worlds_new():
	pass
