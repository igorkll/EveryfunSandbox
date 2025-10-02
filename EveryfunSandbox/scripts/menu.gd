extends Node

var menuUI
var gameUI

func openUI(gameUImode):
	menuUI.visible = not gameUImode
	gameUI.visible = gameUImode
	
	game.camera.setOrbital(not gameUImode)
	game.player.setControlLock(not gameUImode)

func _ready():
	menuUI = get_node("/root/main/gui/container/menuUI")
	gameUI = get_node("/root/main/gui/container/gameUI")
	
	openUI(false)
