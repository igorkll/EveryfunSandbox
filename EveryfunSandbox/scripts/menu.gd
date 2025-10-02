extends Node

var menuUI
var gameUI

func switchUI(ui):
	match ui:
		0:
			menuUI.visible = true
			gameUI.visible = false
			
			game.camera.setOrbital(true)
			game.player.setControlLock(true)
			game.setMouseEnabled(true)
		1:
			menuUI.visible = false
			gameUI.visible = true
			
			game.camera.setOrbital(false)
			game.player.setControlLock(false)
			game.setMouseEnabled(false)

func _ready():
	menuUI = get_node("/root/main/gui/container/menuUI")
	gameUI = get_node("/root/main/gui/container/gameUI")
	
	switchUI(0)
	
	saves.open("test")

func _process(delta):
	if not saves.isWorldFullLoaded():
		switchUI(0)
