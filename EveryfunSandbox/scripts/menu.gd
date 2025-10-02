extends Node

var menuUI
var gameUI

var currentUI

func switchUI(ui):
	if currentUI == ui:
		return
	currentUI = ui
	
	match ui:
		0:
			menuUI.visible = true
			gameUI.visible = false
			
			game.camera.setOrbital(true)
			game.player.setControlLock(true)
			game.setMouseEnabled(true)
			game.setAudioChannelVolume("Other", 0)
		1:
			menuUI.visible = false
			gameUI.visible = true
			
			game.camera.setOrbital(false)
			game.player.setControlLock(false)
			game.setMouseEnabled(false)
			game.applyAudioSettings()

func _ready():
	menuUI = game.mainNode.find_child("menuUI", true, false)
	gameUI = game.mainNode.find_child("gameUI", true, false)
	switchUI(0)
	
	saves.open("test")

func _process(delta):
	if not saves.isWorldFullLoaded():
		switchUI(0)
	elif Input.is_action_just_pressed("menu"):
		if currentUI == 1:
			switchUI(0)
		else:
			switchUI(1)
