extends Node

var list_items = []
var list_item2block = {}

func _prepairGameItems():
	list_items = []
	list_item2block = {}
	
	for obj in blockUtils.list_id2obj:
		var name = "block_" + obj.name + "_r" + str(obj.currentRotation) + "_c" + str(obj.colorVariant) + "_v" + str(obj.baseVariant)
		list_items.append(name)
		list_item2block[name] = obj

# уникальные предметы могут содержать какие то данные прямо внутри себя (это таблица)
func _isUnique(itemobj):
	return typeof(itemobj) == TYPE_DICTIONARY


func itemToBlock(inventory, itemName):
	if inventory.has("items") && inventory.items.has(itemName):
		var itemobj = inventory.items[itemName]
		if _isUnique(itemobj) && itemobj.has("_toBlock"):
			return itemobj["_toBlock"]
	return list_item2block[itemName]

	
func getFreeSpace(inventory) -> int:
	return getTotalSpace(inventory) - getUserSpace(inventory)

func getUserSpace(inventory) -> int:
	var itemCount = 0
	if inventory.has("items"):
		for itemobj in inventory.items.values():
			itemCount += getItemsCount(inventory, itemobj)
	return itemCount
	
func getTotalSpace(inventory) -> int:
	return inventory.maxitems


func getItemsCount(inventory, itemName) -> int:
	if inventory.has("items") && inventory.items.has(itemName):
		var itemobj = inventory.items[itemName]
		if _isUnique(itemobj):
			return 1
		return itemobj
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
		inventory.items[itemName] = itemCount
	else:
		if _isUnique(inventory.items[itemName]):
			return false
			
		inventory.items[itemName] += itemCount
		
	return true

func nonGameDestroyItems(inventory, itemName, itemCount) -> bool:
	if not itemsExists(inventory, itemName, itemCount):
		return false
	
	if not inventory.has("items"):
		inventory.items = {}
	
	if _isUnique(inventory.items[itemName]):
		inventory.items.erase(itemName)
	else:
		inventory.items[itemName] -= itemCount
		if inventory.items[itemName] <= 0:
			inventory.items.erase(itemName)
	
	return true

func transferItem(fromInventory, toInventory, itemName, itemCount) -> bool:
	if not itemsExists(fromInventory, itemName, itemCount):
		return false
		
	if not spaceExists(toInventory, itemCount):
		return false
		
	if not fromInventory.has("items"):
		fromInventory.items = {}
		
	if not toInventory.has("items"):
		toInventory.items = {}
	
	if _isUnique(fromInventory.items[itemName]):
		var itemobj = fromInventory.items[itemName]
		fromInventory.items.erase(itemName)
		toInventory.items[itemName] = itemobj
	else:
		fromInventory.items[itemName] -= itemCount
		if fromInventory.items[itemName] <= 0:
			fromInventory.items.erase(itemName)
		
		toInventory.items[itemName] += itemCount
	
	return true

func placeBlock(terrain, position: Vector3i, inventory, itemName, rotation=0, storageData=null) -> bool:
	if not itemsExists(inventory, itemName, 1):
		return false
		
	nonGameDestroyItems(inventory, itemName, 1)
	
	var obj = itemToBlock(inventory, itemName)
	terrainInteractions.placeBlock(terrain, position, obj.id, rotation, obj.baseVariant, obj.colorVariant, storageData)
	return true
