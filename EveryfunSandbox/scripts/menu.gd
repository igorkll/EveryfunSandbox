extends Node

var menuUI
var showTextUI
var gameUI

var waitSwitchUI = false
var toggleTimeout = 0
var currentUI
var backTo

func fullLock():
	game.player.orbital_camera = true
	game.player.control_lock = true
	game.setMouseEnabled(true)
	game.setMuteAllExceptMusic(true)
	
func fullUnlock():
	game.player.orbital_camera = false
	game.player.control_lock = false
	game.setMouseEnabled(false)
	game.setMuteAllExceptMusic(false)
	
func liteLock():
	fullUnlock()
	game.player.control_lock = true
	game.setMouseEnabled(true)

func switchUI(ui) -> bool:
	if currentUI == ui:
		return false
	currentUI = ui
	
	if not game.player:
		waitSwitchUI = true
		return false
	
	menuUI.visible = false
	gameUI.visible = false
	showTextUI.visible = false
	
	match ui:
		0:
			menuUI.visible = true
			fullLock()
			
		1:
			gameUI.visible = true
			fullUnlock()
			
		2:
			liteLock()
			
		3:
			showTextUI.visible = true
			fullLock()
			
		4:
			showTextUI.visible = true
			liteLock()
	
	return true
			
func showText(text):
	var backToMenu = currentUI == 0 || currentUI == 3
	game.mainNode.find_child("ui_showText_label", true, false).text = text
	backTo = 0 if backToMenu else 1
	switchUI(3 if backToMenu else 4)

func _ready():
	menuUI = game.mainNode.find_child("menuUI", true, false)
	gameUI = game.mainNode.find_child("gameUI", true, false)
	showTextUI = game.mainNode.find_child("showTextUI", true, false)
	switchUI(0)

func _process(delta):
	if not saves.isWorldFullLoaded() && (currentUI == 1 or currentUI == 0):
		switchUI(0)
	elif Input.is_action_just_pressed("menu") && toggleTimeout <= 0:
		if currentUI != 2:
			if currentUI == 3:
				switchUI(0)
			elif currentUI == 1:
				switchUI(0)
			else:
				switchUI(1)
	
	if waitSwitchUI && switchUI(currentUI):
		waitSwitchUI = false
	
	toggleTimeout -= delta
	if toggleTimeout < 0:
		toggleTimeout = 0
