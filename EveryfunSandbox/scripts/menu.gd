extends Node

var menuUI
var showTextUI
var gameUI

var toggleTimeout = 0
var currentUI

func switchUI(ui):
	if currentUI == ui:
		return
	currentUI = ui
	
	menuUI.visible = false
	gameUI.visible = false
	showTextUI.visible = false
	
	match ui:
		0:
			menuUI.visible = true
			
			game.camera.setOrbital(true)
			game.player.setControlLock(true)
			game.setMouseEnabled(true)
			game.setMuteAllExceptMusic(true)
		1:
			gameUI.visible = true
			
			game.camera.setOrbital(false)
			game.player.setControlLock(false)
			game.setMouseEnabled(false)
			game.setMuteAllExceptMusic(false)
		2:
			game.camera.setOrbital(false)
			game.player.setControlLock(true)
			game.setMouseEnabled(true)
			game.setMuteAllExceptMusic(false)
		3:
			showTextUI.visible = true
			
			game.camera.setOrbital(true)
			game.player.setControlLock(true)
			game.setMouseEnabled(true)
			game.setMuteAllExceptMusic(true)
			
func showText(text):
	game.mainNode.find_child("ui_showText_label", true, false).text = text
	switchUI(3)

func _ready():
	menuUI = game.mainNode.find_child("menuUI", true, false)
	gameUI = game.mainNode.find_child("gameUI", true, false)
	showTextUI = game.mainNode.find_child("showTextUI", true, false)
	switchUI(0)
	
	if saves.exists("test"):
		saves.open("test")
	else:
		saves.create("test")

func _process(delta):
	if not saves.isWorldFullLoaded():
		switchUI(0)
	elif Input.is_action_just_pressed("menu") && toggleTimeout <= 0:
		if currentUI != 2:
			if currentUI == 1:
				switchUI(0)
			else:
				switchUI(1)
	
	toggleTimeout -= delta
	if toggleTimeout < 0:
		toggleTimeout = 0
