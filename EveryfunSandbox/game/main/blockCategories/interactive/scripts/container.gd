extends baseblock

func _requestDefaultStorageData():
	return {
		inventory = {maxitems = scriptData.get("maxitems", 2000)}
	}

func _use():
	modalUI.inventoryGui(scriptData.get("title", "container"), storageData.inventory, lastUsedPlayer.storageData.inventory)
