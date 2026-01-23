extends Node

var inputModalScene = preload("res://gui/modalUI/input.tscn")
var messageModalScene = preload("res://gui/modalUI/message.tscn")
var acceptModalScene = preload("res://gui/modalUI/accept.tscn")
var inventoryModalScene = preload("res://gui/modalUI/inventory.tscn")

var inventoryItemScene = preload("res://gui/inventoryItem/inventoryItem.tscn")

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
	
func _transfer(inventory, itemName, transferToInventory, count):
	inventoryUtils.transferItem(inventory, transferToInventory, itemName, count)
	
func _addInventoryItem(modal, inventory, itemName, transferToInventory=null, onItemSelect=null):
	var inventoryItem = inventoryItemScene.instantiate()
	funcs.ui_set_text(inventoryItem, "name", inventoryUtils.getItemUiName(inventory, itemName))
	
	if inventoryUtils.isUniqueItem(inventory, itemName):
		funcs.paint_panel(modal, Color(0.731, 0.271, 0.72, 1.0))
	
	if transferToInventory == null:
		funcs.ui_hide(inventoryItem, "transferButton")
	else:
		funcs.ui_button_callback(inventoryItem, "transferButton", _transfer.bind(inventory, itemName, transferToInventory, 1))
		
	if onItemSelect == null:
		funcs.ui_hide(inventoryItem, "selectButton")
	else:
		funcs.ui_button_callback(inventoryItem, "selectButton", onItemSelect.bind(inventory, itemName))
		
	funcs.ui_get_item(modal, "items").add_child(inventoryItem)

func inventoryGui(title, inventory, transferToInventory=null, onItemSelect=null):
	var modal = inventoryModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	
	if inventory.has("items"):
		var keys = inventory["items"].keys()
		keys.sort()

		for itemName in keys:
			if inventoryUtils.isUniqueItem(inventory, itemName):
				_addInventoryItem(modal, inventory, itemName)
				
		for itemName in keys:
			_addInventoryItem(modal, inventory, itemName)
	
	menu.openUI(modal)

func textModal(text="test"):
	menu.showText(text)

func close():
	if menu.currentUI != 0 && menu.currentUI != 1:
		menu.switchUI(menu.backTo)
