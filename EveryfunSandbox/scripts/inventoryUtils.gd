extends Node

var gameItems = []
var item2block = {}

func _prepairGameItems():
	gameItems = []
	item2block = {}
	
	for obj in blockUtils.list_id2obj:
		var name = "block_" + obj.name + "_r" + str(obj.currentRotation) + "_c" + str(obj.colorVariant) + "_v" + str(obj.baseVariant)
		gameItems.append(name)
		item2block[name] = obj
		
	
func getFreeSpace(inventory) -> int:
	return getTotalSpace(inventory) - getUserSpace(inventory)

func getUserSpace(inventory) -> int:
	var itemCount = 0
	if inventory.has("items"):
		for count in inventory.values():
			itemCount += count
	return itemCount
	
func getTotalSpace(inventory) -> int:
	return inventory.maxitems


func getItemsCount(inventory, itemName) -> int:
	if inventory.has("items") && inventory.items.has(itemName):
		return inventory.items[itemName]
	return 0

func itemsExists(inventory, itemName, count):
	return getItemsCount(inventory, itemName) >= count

func spaceExists(inventory, count):
	return getFreeSpace(inventory) >= count


func nonGameCreateItems(inventory, itemName, itemCount) -> bool:
	if not spaceExists(inventory, itemCount):
		return false
		
	if not inventory.has("items"):
		inventory.items = {}
		
	if not inventory.items.has(itemName):
		inventory.items[itemName] = 0
		
	inventory.items[itemName] += itemCount
		
	return true

func nonGameDestroyItems(inventory, itemName, itemCount) -> bool:
	if not itemsExists(inventory, itemName, itemCount):
		return false
	
	if not inventory.has("items"):
		inventory.items = {}
		
	inventory.items[itemName] -= itemCount
	
	return true

func transferItem(fromInventory, toInventory, itemName, itemCount) -> bool:
	if not itemsExists(fromInventory, itemName, itemCount):
		return false
		
	if not spaceExists(toInventory, itemCount):
		return false
		
	if not fromInventory.has("items"):
		fromInventory.items = {}
		
	if not fromInventory.items.has(itemName):
		fromInventory.items[itemName] = 0
		
	if not toInventory.has("items"):
		toInventory.items = {}
		
	if not toInventory.items.has(itemName):
		toInventory.items[itemName] = 0
		
	fromInventory.items[itemName] -= itemCount
	toInventory.items[itemName] += itemCount
	
	return true
