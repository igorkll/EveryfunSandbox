extends Node

var guiContainer
var inputModalScene = preload("res://gui/modalUI/input.tscn")

func _ready():
	guiContainer = get_node("/root/main/gui")

func inputModal(title):
	var modal = inputModalScene.instantiate()
	guiContainer.add_child(modal)
	menu.setAltUI(modal)
