extends Node

func blockSound(terrain, soundName, position: Vector3i, blockId=null):
	if blockId == null:
		blockId = terrain.voxel_tool.get_voxel(position)
	
	var item = blockUtils.list_id2obj[blockId]
	if item.has(soundName):
		game.playSound(game.soundList[item.sound_place], terrainUtils.getGlobalPositionFromVoxelPosition(terrain, position))

func attackCheck(blockId: int, attackLevel: float):
	var info = blockUtils.getInfo(blockId)
	return info.durability > 0 && attackLevel > 0 && (attackLevel >= info.durability || randf() < ((attackLevel / info.durability) * consts.chance_multiplier_to_destroy_a_block_of_greater_strength))

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, color=0, storageData=null):
	blockSound(terrain, "sound_place", position, blockId)
	terrainUtils.placeBlock(terrain, position, blockId, rotation, variant, color, storageData)

func destroyBlock(terrain, position: Vector3i, attackLevel=null) -> bool:
	if attackLevel != null && not attackCheck(terrain.voxel_tool.get_voxel(position), attackLevel):
		return false
	
	blockSound(terrain, "sound_destroy", position)
	terrainUtils.destroyBlock(terrain, position)
	return true

func _getBlockDestroyTime(terrain, position):
	return terrainUtils.getBlockInfo(terrain, position).durability * consts.one_durability_destroy_seconds	

func _updateHit(hitInfo):
	var blockDestroyTime = _getBlockDestroyTime(hitInfo["terrain"], hitInfo["position"])
	var percent = hitInfo["timer"] / blockDestroyTime
	
	if not hitInfo.has("effect"):
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1.005, 1.005, 1.005)
	
		var effect = MeshInstance3D.new()
		effect.mesh = box_mesh
		effect.position = terrainUtils.getGlobalPositionFromVoxelPosition(hitInfo["terrain"], hitInfo["position"])
		effect.material_override = StandardMaterial3D.new()
		effect.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		game.objects.add_child(effect)
		hitInfo["effect"] = effect
	
	hitInfo["effect"].material_override.albedo_color = Color(1, 1, 1, percent)
	
func hitBlock(terrain, position: Vector3i, hitInfo, delta) -> bool:
	if hitInfo.has("timer") and (hitInfo.terrain != terrain or hitInfo.position != position):
		hitInfo["effect"].queue_free()
		hitInfo.clear()
		
	if not hitInfo.has("timer"):
		hitInfo["timer"] = 0
		hitInfo["hitTimer"] = 0
		hitInfo["terrain"] = terrain
		hitInfo["position"] = position
	
	hitInfo["timer"] += delta
	hitInfo["hitTimer"] += delta
	
	if hitInfo["hitTimer"] > 0.2:
		blockSound(terrain, "sound_hit", position)
		hitInfo["hitTimer"] = 0
	
	_updateHit(hitInfo)
	
	var blockDestroyTime = _getBlockDestroyTime(terrain, position)
	var destroyFlag = hitInfo["timer"] > blockDestroyTime
	if destroyFlag:
		hitInfo["effect"].queue_free()
		hitInfo.clear()
	return destroyFlag
	
func hitCheck(hitInfo, delta):
	if hitInfo.has("timer"):
		hitInfo["timer"] -= delta
		
		_updateHit(hitInfo)
		
		if hitInfo["timer"] <= 0:
			hitInfo["effect"].queue_free()
			hitInfo.clear()
	
	
