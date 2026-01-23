extends baseblock

func _requestDefaultStorageData():
	return {
		inventory = {}
	}

func _use():
	storageData.inventory.maxitems = scriptData.get("maxitems", 2000)
	modalUI.inventoryGui(scriptData.get("title", "container"), storageData.inventory, lastUsedPlayer.storageData.inventory)
