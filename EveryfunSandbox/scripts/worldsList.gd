extends Node

var ui_worlds_list

func addWorldToList():
	pass

func updateWorldsList():
	for child in ui_worlds_list.get_children():
		child.queue_free()
		
	for worldName in saves.list():
		addWorldToList(worldName)

func _ready():
	ui_worlds_list = game.mainNode.find_child("ui_worlds_list", true, false)
	gui._attachButton("ui_worlds_new", _worlds_new)
	updateWorldsList()

func _worlds_new():
	pass
