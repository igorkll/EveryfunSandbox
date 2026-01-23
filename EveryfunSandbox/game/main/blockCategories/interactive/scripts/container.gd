extends baseblock

func _requestDefaultStorageData():
	return {
		inventory = {}
	}

func _use():
	storageData.inventory.maxitems = scriptData.get("maxitems", 2000)
	modalUI.inventory2Gui(scriptData.get("title", "container"), storageData.inventory, "inventory", lastUsedPlayer.storageData.inventory)
