extends Node

var worldCardBase = preload("res://worldCard.tscn")

var defaultWorldName = "default world"
var ui_worlds_list

func addWorldToList(worldName):
	var worldCard = worldCardBase.instantiate()
	
	ui_worlds_list.add_child(worldCard)

func updateWorldsList():
	for child in ui_worlds_list.get_children():
		child.queue_free()
		
	for worldName in saves.list():
		addWorldToList(worldName)
		
	addWorldToList("1")
	addWorldToList("2")
	addWorldToList("3")
	
	ui_worlds_list.queue_sort()

func openDefaultWorld():
	if game.settings.data.selectedWorld != null:
		if saves.exists(game.settings.data.selectedWorld):
			saves.open(game.settings.data.selectedWorld)
		else:
			game.settings.data.selectedWorld = null
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
