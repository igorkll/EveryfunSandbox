extends Node

var list_items = []
var list_item2block = {}
var list_blockid2item = {}
var list_item2uiname = {}

func _prepairGameItems():
	list_items = []
	list_item2block = {}
	list_blockid2item = {}
	list_item2uiname = {}
	
	for obj in blockUtils.list_id2obj:
		var name = "block_" + obj.name + "_r" + str(obj.currentRotation) + "_c" + str(obj.colorVariant) + "_v" + str(obj.baseVariant)
		list_items.append(name)
		list_item2block[name] = obj
		list_blockid2item[obj.id] = name
		list_item2uiname[name] = obj.name

# уникальные предметы могут содержать какие то данные прямо внутри себя (это таблица)
func _isUnique(itemobj):
	return typeof(itemobj) == TYPE_DICTIONARY

func _uniqueSuffix():
	var uniqueSuffix = "_unique"
	for i in range(16):
		uniqueSuffix += str(randi_range(0, 9))
	return uniqueSuffix




func getItemName(inventory, itemName):
	if inventory.has("items") && inventory.items.has(itemName):
		var itemobj = inventory.items[itemName]
		if _isUnique(itemobj) && itemobj.has("_sourceItem"):
			return itemobj["_sourceItem"]
	return itemName
	
func getItemUiName(inventory, itemName):
	var sourceItemName = getItemName(inventory, itemName)
	if list_item2uiname.has(sourceItemName):
		return list_item2uiname[sourceItemName]
	return sourceItemName

func itemToBlock(inventory, itemName):
	var sourceItemName = getItemName(inventory, itemName)
	if list_item2block.has(sourceItemName):	
		return list_item2block[sourceItemName]
	return null




func getFreeSpace(inventory) -> int:
	return getTotalSpace(inventory) - getUsedSpace(inventory)

func getUsedSpace(inventory) -> int:
	var itemCount = 0
	if inventory.has("items"):
		for itemName in inventory.items.keys():
			itemCount += getItemsCount(inventory, itemName)
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
	
func nonGameCreateUniqueItem(inventory, itemName, itemData=null, uniqueItemName=null) -> bool:
	if not spaceExists(inventory, 1):
		return false
	
	if uniqueItemName == null:
		uniqueItemName = itemName + _uniqueSuffix()
	
	if not inventory.has("items"):
		inventory.items = {}
	
	if inventory.items.has(uniqueItemName):
		return false
	
	if itemData == null:
		itemData = {}
	
	itemData["_sourceItem"] = itemName
	inventory.items[uniqueItemName] = itemData
			
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
			
		if not toInventory.items.has(itemName):
			toInventory.items[itemName] = 0
		toInventory.items[itemName] += itemCount
	
	return true




func placeBlock(terrain, position: Vector3i, inventory, itemName, rotation=0, storageData=null) -> bool:
	if not itemsExists(inventory, itemName, 1):
		return false
	
	var blockobj = itemToBlock(inventory, itemName)
	if storageData == null && isUniqueItem(inventory, itemName):
		storageData = getUniqueItemData(inventory, itemName)
		storageData["_uniqueItem"] = itemName
		storageData.erase("_sourceItem")
	
	nonGameDestroyItems(inventory, itemName, 1)
	terrainInteractions.placeBlock(terrain, position, blockobj.id, rotation, blockobj.baseVariant, blockobj.colorVariant, storageData)
	return true

# автоматически создает уникальный предмет если то нужно блоку
func destroyBlock(terrain, position: Vector3i, inventory, attackLevel=null) -> bool:
	var blockId = terrainUtils.getBlockId(terrain, position)
	var blockData = terrainUtils.getBlockStorageData(terrain, position)
	var itemName = list_blockid2item[blockId]
	
	var destroyed = terrainInteractions.destroyBlock(terrain, position, attackLevel)
	if destroyed:
		if blockData.has("_uniqueItem"):
			if typeof(blockData["_uniqueItem"]) == TYPE_STRING:
				nonGameCreateUniqueItem(inventory, itemName, blockData, blockData["_uniqueItem"])
			else:
				nonGameCreateUniqueItem(inventory, itemName, blockData)
		else:
			nonGameCreateItems(inventory, itemName, 1)
	return destroyed




func isUniqueItem(inventory, itemName):
	if inventory.has("items") && inventory.items.has(itemName):
		return _isUnique(inventory.items[itemName])
	return false
	
func isBlockItem(inventory, itemName):
	var sourceItemName = getItemName(inventory, itemName)
	return list_item2block.has(sourceItemName)

func getUniqueItemData(inventory, itemName):
	if isUniqueItem(inventory, itemName):
		return inventory.items[itemName]
	return null

func makeUniqueItem(inventory, itemName, itemData=null):
	if isUniqueItem(inventory, itemName):
		return false
		
	if not itemsExists(inventory, itemName, 1):
		return false
	
	nonGameDestroyItems(inventory, itemName, 1)
	nonGameCreateUniqueItem(inventory, itemName, itemData)
	return true
