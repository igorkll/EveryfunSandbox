extends baseblock

func _requestDefaultStorageData():
	return {
		inventory = {}
	}
	
func _process(delta):
	storageData._indestructible = not inventoryUtils.isEmpty(storageData.inventory)

func _use():
	storageData.inventory.maxitems = scriptData.get("maxitems", 2000)
	modalUI.inventory2Gui(scriptData.get("title", "crafting table"), storageData.inventory, "inventory", lastUsedPlayer.storageData.inventory)
