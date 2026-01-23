extends Node

var inputModalScene = preload("res://gui/modalUI/input.tscn")
var messageModalScene = preload("res://gui/modalUI/message.tscn")
var acceptModalScene = preload("res://gui/modalUI/accept.tscn")
var inventoryModalScene = preload("res://gui/modalUI/inventory.tscn")
var inventory2ModalScene = preload("res://gui/modalUI/inventory2.tscn")

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
	if count == -1:
		count = inventoryUtils.getItemsCount(inventory, itemName) / 2
	elif count == -2:
		count = inventoryUtils.getItemsCount(inventory, itemName)
	inventoryUtils.transferItem(inventory, transferToInventory, itemName, count)
	
func _addInventoryItem(modal, inventory, itemName, transferToInventory=null, onItemSelect=null):
	var inventoryItem = inventoryItemScene.instantiate()
	var uiName = inventoryUtils.getItemUiName(inventory, itemName)
	var count = inventoryUtils.getItemsCount(inventory, itemName)
	if count > 1:
		uiName += " x" + str(count)
	funcs.ui_set_text(inventoryItem, "name", uiName)
	
	if inventoryUtils.isUniqueItem(inventory, itemName):
		funcs.paint_panel(inventoryItem, Color(0.746, 0.522, 0.77, 1.0))
	
	if transferToInventory == null:
		funcs.ui_hide(inventoryItem, "transferButton")
		funcs.ui_hide(inventoryItem, "transferHalfButton")
		funcs.ui_hide(inventoryItem, "transferAllButton")
	else:
		funcs.ui_button_callback(inventoryItem, "transferButton", _transfer.bind(inventory, itemName, transferToInventory, 1))
		funcs.ui_button_callback(inventoryItem, "transferHalfButton", _transfer.bind(inventory, itemName, transferToInventory, -1))
		funcs.ui_button_callback(inventoryItem, "transferAllButton", _transfer.bind(inventory, itemName, transferToInventory, -2))
		
	if onItemSelect == null:
		funcs.ui_hide(inventoryItem, "selectButton")
	else:
		funcs.ui_button_callback(inventoryItem, "selectButton", onItemSelect.bind(inventory, itemName))
		
	funcs.ui_get_item(modal, "items").add_child(inventoryItem)

func _addAllInventoryItems(modal, inventory, transferToInventory=null, onItemSelect=null):
	if inventory.has("items"):
		var keys = inventory["items"].keys()
		keys.sort()

		for itemName in keys:
			if inventoryUtils.isUniqueItem(inventory, itemName):
				_addInventoryItem(modal, inventory, itemName, transferToInventory, onItemSelect)
				
		for itemName in keys:
			if not inventoryUtils.isUniqueItem(inventory, itemName):
				_addInventoryItem(modal, inventory, itemName, transferToInventory, onItemSelect)

func _setInventoryInfo(modal, inventory):
	funcs.ui_set_text(modal, "inventorySpace", str(inventoryUtils.getUsedSpace(inventory)) + " / " + str(inventoryUtils.getTotalSpace(inventory)))

func inventoryGui(title, inventory, transferToInventory=null, onItemSelect=null):
	var modal = inventoryModalScene.instantiate()
	funcs.ui_set_text(modal, "title", title)
	_setInventoryInfo(modal, inventory)
	_addAllInventoryItems(modal, inventory, transferToInventory, onItemSelect)
	menu.openUI(modal)
	return modal
	
func inventory2Gui(title, inventory, title2, inventory2):
	var realModal = inventory2ModalScene.instantiate()
	var invTop = funcs.ui_get_item(realModal, "invTop")
	var invBottom = funcs.ui_get_item(realModal, "invBottom")
	
	funcs.ui_set_text(invTop, "title", title)
	_setInventoryInfo(invTop, inventory)
	_addAllInventoryItems(invTop, inventory, inventory2)
	
	funcs.ui_set_text(invBottom, "title", title2)
	_setInventoryInfo(invBottom, inventory2)
	_addAllInventoryItems(invBottom, inventory2, inventory)
	
	menu.openUI(realModal)
	return realModal

func textModal(text="test"):
	menu.showText(text)

func close():
	if menu.currentUI != 0 && menu.currentUI != 1:
		menu.switchUI(menu.backTo)
