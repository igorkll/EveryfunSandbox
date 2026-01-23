extends Node

var inputModalScene = preload("res://gui/modalUI/input.tscn")
var messageModalScene = preload("res://gui/modalUI/message.tscn")
var acceptModalScene = preload("res://gui/modalUI/accept.tscn")
var inventoryModalScene = preload("res://gui/modalUI/inventory.tscn")

func messageModal(title, text, callback=null):
	var modal = messageModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	funcs.ui_set_text(modal, "text", text)
	funcs.ui_button_callback(modal, "done", func():
		close()
		if callback:
			callback.call()
	)
	menu.openUI(modal)
	
func acceptModal(title, text, callback=null):
	var modal = acceptModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	funcs.ui_set_text(modal, "text", text)
	funcs.ui_button_callback(modal, "cancel", func():
		close()
		if callback:
			callback.call(false)
	)
	funcs.ui_button_callback(modal, "accept", func():
		close()
		if callback:
			callback.call(true)
	)
	menu.openUI(modal)

func inputModal(title, callback=null, value=""):
	var modal = inputModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	funcs.ui_set_text(modal, "input", value)
	funcs.ui_button_callback(modal, "cancel", func():
		close()
		if callback:
			callback.call(null)
	)
	funcs.ui_button_callback(modal, "confirm", func():
		close()
		if callback:
			callback.call(funcs.ui_get_text(modal, "input"))
	)
	menu.openUI(modal)
	
func inventoryGui(title, callback, inventory, transferToInventory):
	var modal = inventoryModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	

func textModal(text="test"):
	menu.showText(text)

func close():
	if menu.currentUI != 0 && menu.currentUI != 1:
		menu.switchUI(menu.backTo)
