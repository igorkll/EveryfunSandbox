extends Node

var menuUI
var gameUI

func openUI(gameUImode):
	menuUI.visible = not gameUImode
	gameUI.visible = gameUImode

func _ready():
	menuUI = get_node("/root/main/gui/container/menuUI")
	gameUI = get_node("/root/main/gui/container/gameUI")
	
	openUI(true)
