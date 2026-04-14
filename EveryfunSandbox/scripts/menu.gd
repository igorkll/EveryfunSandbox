extends Node

var guiContainer
var showTextUI

var menuUI
var gameUI
var altMenuUI
var altMenuUIAutoDelete = false

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
	if currentUI == ui && not waitSwitchUI:
		return false
	currentUI = ui
	
	if not game.player:
		waitSwitchUI = true
		return false
	
	menuUI.visible = false
	gameUI.visible = false
	
	if altMenuUI:
		altMenuUI.visible = false
		
	if altMenuUIAutoDelete && currentUI != 3 && currentUI != 4:
		altMenuUIAutoDelete = false
		altMenuUI.queue_free()
	
	match ui:
		0: # menu
			menuUI.visible = true
			fullLock()
			
		1: # game
			gameUI.visible = true
			fullUnlock()
			
		2:
			liteLock()
			
		3:
			if altMenuUI:
				altMenuUI.visible = true
			fullLock()
			
		4:
			if altMenuUI:
				altMenuUI.visible = true
			liteLock()
	
	return true
	
func setAltUI(altMenu, autoDelete=false):
	var oldVisible = false
	if altMenuUI:
		altMenuUI.visible = false
		oldVisible = true
	
	if altMenuUIAutoDelete:
		altMenuUI.queue_free()
	
	altMenuUIAutoDelete = autoDelete
	altMenuUI = altMenu
	altMenuUI.visible = oldVisible
	
	var backToMenu = currentUI == 0 || currentUI == 3
	backTo = 0 if backToMenu else 1
	switchUI(3 if backToMenu else 4)
	
func openUI(altMenu):
	setAltUI(altMenu, true)
	guiContainer.add_child(altMenu)

func showText(text):
	showTextUI.find_child("ui_showText_label", true, false).text = text
	setAltUI(showTextUI)

func _ready():
	guiContainer = get_node("/root/main/gui")
	menuUI = game.mainNode.find_child("menuUI", true, false)
	gameUI = game.mainNode.find_child("gameUI", true, false)
	showTextUI = game.mainNode.find_child("showTextUI", true, false)
	switchUI(0)

func _process(delta):
	if not saves.isWorldFullLoaded() && (currentUI == 1 or currentUI == 0):
		switchUI(0)
	elif Input.is_action_just_pressed("menu") && toggleTimeout <= 0:
		if game.player.chatOpened:
			game.player.chatOpened = false
			menu.switchUI(1)
		else:
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
