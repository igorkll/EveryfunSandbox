extends Node

func blockRaycast(position: Vector3, direction, maxDistance):
	var terrain = game.terrain
	
	var result = terrain.voxel_tool.raycast(position, direction, maxDistance)
	if result:
		return [terrain, result]
		
func getTerrain(terrain):
	if terrain is RigidBody3D:
		return terrain.get_child(0)
	return terrain
		
func attachBlockChild(terrain, position: Vector3i, child):
	terrain = getTerrain(terrain)
	if not terrain.blockChildren.has(position):
		terrain.blockChildren[position] = []
	terrain.blockChildren[position].append(child)
	terrain.add_child(child)
	game.allTerrainNodes.append(child)
	
func deleteBlockChild(terrain, position, child):
	terrain = getTerrain(terrain)
	terrain.blockChildren[position].erase(child)
	child.queue_free()
	game.allTerrainNodes.erase(child)
	
func deleteBlockChildrenWithTypes(terrain, position: Vector3i, types):
	terrain = getTerrain(terrain)
	var children = terrain.blockChildren.get(position)
	if children:
		for i in range(children.size() - 1, -1, -1):
			var child = children[i]
			if child.get_class() in types:
				deleteBlockChild(terrain, position, child)
				
func deleteBlockChildrenWithScript(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var children = terrain.blockChildren.get(position)
	if children:
		for i in range(children.size() - 1, -1, -1):
			var child = children[i]
			if child.get_script() != null:
				deleteBlockChild(terrain, position, child)
	
func getBlockChildren(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	if terrain.blockChildren.has(position):
		return terrain.blockChildren[position]
	else:
		return []
		
func isBlockScript(terrain, position: Vector3i) -> bool:
	terrain = getTerrain(terrain)
	return getBlockScript(terrain, position) != null
		
func _updateChildrenRotation(terrain, position: Vector3i, blockId=null):
	if blockId == null:
		blockId = terrain.voxel_tool.get_voxel(position)
	
	var voxelItem = blockUtils.list_id2obj[blockId]
	var children = getBlockChildren(terrain, position)

	var lightIndex = 0
	for child in children:
		var rotations = []
		
		if voxelItem.has("rotation"):
			rotations.append(voxelItem.rotation.r)
		
		if child is OmniLight3D || child is SpotLight3D:
			rotations.append(funcs.arr_to_Vector3(voxelItem.lights[lightIndex].get("rotation", [0, 0, 0])))
			lightIndex += 1
			
		child.rotation_degrees = funcs.combine_rotations_deg(rotations)

func _getScriptChecksum(obj):
	return hash([obj.get("script"), obj.get("script_data")])
	
func _getLoadBlockData(terrain, position: Vector3i, blockId=null, storageData=null):
	if blockId == null || storageData == null:
		var voxel = saves.getInteractiveVoxel(terrain, position)
		if voxel:
			if blockId == null:
				blockId = voxel[0]
			if storageData == null:
				storageData = voxel[1]
		else:
			if blockId == null:
				blockId = getBlockId(terrain, position)
			if storageData == null:
				storageData = blockUtils.getDefaultStorageData(blockId)
	return [blockId, storageData]

func loadBlockScript(terrain, position: Vector3i, blockId=null, storageData=null):
	terrain = getTerrain(terrain)
	var loadBlockData = _getLoadBlockData(terrain, position, blockId, storageData)
	blockId = loadBlockData[0]
	storageData = loadBlockData[1]
	
	var obj = blockUtils.list_id2obj[blockId]
	var script = game.loadResource(obj.script)
	var node = script.new()
	
	node.position = Vector3(position) + Vector3(0.5, 0.5, 0.5)
	node.storageData = storageData
	node.scriptData = obj.get("script_data", {})
	
	node.voxelTerrain = terrain
	node.voxelPosition = position
	node.voxelRotation = obj.currentRotation
	node.voxelVariant = obj.currentVariant
	node.voxelBaseVariant = obj.baseVariant
	node.voxelColorVariant = obj.colorVariant
	node.voxelDirection = Vector3i(1, 0, 0)
	node.voxelDirectionUp = Vector3i(0, 1, 0)
	
	node.voxelBaseBlockId = obj.baseId
	node.voxelBaseBlockItem = blockUtils.list_id2obj[obj.baseId]
	
	node.voxelBlockId = blockId
	node.voxelBlockItem = obj
	
	if obj.has("rotation"):
		node.voxelDirection = obj.rotation.d
		node.voxelDirectionUp = obj.rotation.u
	
	attachBlockChild(terrain, position, node)
	
func checkTempScript(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	
	if !obj.get("script_temp") || isBlockScript(terrain, position):
		return
	
	if not saves.isNotTempInteractiveVoxel(terrain, position):
		var loadBlockData = _getLoadBlockData(terrain, position)
		saves.regInteractiveVoxel(terrain, position, loadBlockData[0], loadBlockData[1], true)
		
	var loadBlockData = _getLoadBlockData(terrain, position)
	var blockId = loadBlockData[0]
	var storageData = loadBlockData[1]
	
	loadBlockScript(terrain, position, blockId, storageData)
	_updateChildrenRotation(terrain, position, blockId)
	
func checkUnloadTempScript(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	
	if !obj.get("script_temp") || !obj.get("script_temp_destroy"):
		return
	
	if saves.isTempInteractiveVoxel(terrain, position):
		saves.regInteractiveVoxel(terrain, position, null)
	
	deleteBlockChildrenWithScript(terrain, position)
	
func getBlockObj(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	return blockUtils.list_id2obj[terrain.voxel_tool.get_voxel(position)]
	
func getBlockId(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	return terrain.voxel_tool.get_voxel(position)

func loadBlock(terrain, position: Vector3i, blockId=null, storageData=null):
	terrain = getTerrain(terrain)
	var loadBlockData = _getLoadBlockData(terrain, position, blockId, storageData)
	blockId = loadBlockData[0]
	storageData = loadBlockData[1]
	
	var exists = terrain.blockChildren.has(position)
	var obj = blockUtils.list_id2obj[blockId]
	var oldObj = getBlockObj(terrain, position)
	var childPos = Vector3(position) + Vector3(0.5, 0.5, 0.5)
	var children = getBlockChildren(terrain, position)
	
	if obj.has("script") and (not exists or _getScriptChecksum(obj) != _getScriptChecksum(oldObj)) and (!obj.get("script_temp") or isBlockScript(terrain, position)):
		deleteBlockChildrenWithScript(terrain, position)
		loadBlockScript(terrain, position, blockId, storageData)
	
	deleteBlockChildrenWithTypes(terrain, position, ["OmniLight3D", "SpotLight3D"])
	if obj.has("lights"):
		for lightData in obj.lights:
			var lightObj
			match lightData.type:
				"omni":
					lightObj = OmniLight3D.new()
					lightObj.omni_shadow_mode = OmniLight3D.SHADOW_DUAL_PARABOLOID
					lightObj.omni_attenuation = lightData.get("attenuation", lightObj.omni_attenuation)
					lightObj.omni_range = lightData.get("range", lightObj.omni_range)

				"spot":
					lightObj = SpotLight3D.new()
					lightObj.spot_angle = lightData.get("angle", lightObj.spot_angle)
					lightObj.spot_angle_attenuation = lightData.get("angle_attenuation", lightObj.spot_angle_attenuation)
					lightObj.spot_attenuation = lightData.get("attenuation", lightObj.spot_attenuation)
					lightObj.spot_range = lightData.get("range", lightObj.spot_range)
				_:
					print("unknown light type")
			
			var graphicSettingsPreset = game.getGraphicSettingsPresets()
			lightObj.shadow_enabled = true
			lightObj.light_color = Color(lightData.get("color", "#ffffff"))
			game.applyLightGraphicSettings(lightObj)
			
			lightObj.position = childPos + lightData.get("position", Vector3(0, 0, 0))
			attachBlockChild(terrain, position, lightObj)
			
	_updateChildrenRotation(terrain, position, blockId)
		
func unloadBlock(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	if terrain.blockChildren.has(position):
		for obj in terrain.blockChildren[position]:
			game.allTerrainNodes.erase(obj)
			obj.queue_free()
		terrain.blockChildren.erase(position)

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, color=0, storageData=null):
	terrain = getTerrain(terrain)
	if not isEditable(terrain, position):
		terrain.deferredActions.append([1, position, blockId, rotation, variant, color, storageData])
		return
	
	if storageData == null:
		storageData = blockUtils.getDefaultStorageData(blockId)
	
	blockId = blockUtils.getVariantBlockId(blockId, rotation, variant, color)
	
	terrain.voxel_tool.set_voxel(position, blockId)
	
	if blockUtils.isInteractive(blockId):
		saves.regInteractiveVoxel(terrain, position, blockId, storageData)
	
	if saves.isInteractiveChunkBlockLoaded(position):
		loadBlock(terrain, position, blockId, storageData)

func destroyBlock(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	if not isEditable(terrain, position):
		terrain.deferredActions.append([0, position])
		return
	
	unloadBlock(terrain, position)
	saves.regInteractiveVoxel(terrain, position, null)
	terrain.voxel_tool.set_voxel(position, 0)
	setVoxelMetadata(terrain, position, null)
	
func applyDeferredActions(terrain):
	terrain = getTerrain(terrain)
	for deferredAction in terrain.deferredActions:
		if isEditable(terrain, deferredAction[1]):
			if deferredAction[0] == 0:
				destroyBlock(terrain, deferredAction[1])
			elif deferredAction[0] == 1:
				placeBlock(terrain, deferredAction[1], deferredAction[2], deferredAction[3], deferredAction[4], deferredAction[5], deferredAction[6])
			deferredAction[0] = -1
	
	for i in range(terrain.deferredActions.size() - 1, -1, -1):
		var deferredAction = terrain.deferredActions[i]
		if deferredAction[0] < 0:
			terrain.deferredActions.remove_at(i)

func callBlock(terrain, position: Vector3i, method, ...args) -> bool:
	terrain = getTerrain(terrain)
	var children = getBlockChildren(terrain, position)
	var result = false
	for child in children:
		if child.has_method(method):
			if child.callv(method, args):
				result = true
	return result

func useBlock(terrain, position: Vector3i) -> bool:
	terrain = getTerrain(terrain)
	if not canUseBlock(terrain, position):
		return false
	
	checkTempScript(terrain, position)
	
	var script = getBlockScript(terrain, position)
	if script != null && script.has_method("_use"):
		script.call("_use")
		
	checkUnloadTempScript(terrain, position)
	
	return true

func canUseBlock(terrain, position: Vector3i) -> bool:
	terrain = getTerrain(terrain)
	var script = getBlockScript(terrain, position)
	
	if script == null:
		var obj = getBlockObj(terrain, position)
		return obj.get("script_default_usage", false)
	elif script.has_method("_canUse"):
		return bool(script.call("_canUse"))
	elif script.has_method("_use"):
		return true
	
	return false
	
func getBlockScript(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var children = getBlockChildren(terrain, position)
	for child in children:
		if child.get_script() != null:
			return child

func getVoxelPositionFromGlobalPosition(terrain, position: Vector3) -> Vector3i:
	terrain = getTerrain(terrain)
	return funcs.vec3_to_vec3i_down(position - terrain.global_transform.origin)

func getGlobalPositionFromVoxelPosition(terrain, position: Vector3i) -> Vector3:
	terrain = getTerrain(terrain)
	return terrain.global_transform.origin + Vector3(position.x, position.y, position.z) + Vector3(0.5, 0.5, 0.5)

func isCellFree(terrain, position: Vector3i) -> bool:
	terrain = getTerrain(terrain)
	if getBlockId(terrain, position) != 0:
		return false
	
	var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.8, 0.8, 0.8)
	query.shape = shape
	query.transform = Transform3D(Basis(), getGlobalPositionFromVoxelPosition(terrain, position))
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	return results.size() == 0

func isMinimalAreaLoaded(terrain, position):
	terrain = getTerrain(terrain)
	var aabb = AABB(
		position - (consts.minimum_loading_radius_for_play / 2),
		consts.minimum_loading_radius_for_play)
	return terrain.voxel_tool.is_area_editable(aabb)
	
func isEditable(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var aabb = AABB(position, Vector3i(1, 1, 1))
	return terrain.voxel_tool.is_area_editable(aabb)

func setRotationAndVariantAndColor(terrain, position: Vector3i, rotation, variant, color):
	terrain = getTerrain(terrain)
	var voxelId = terrain.voxel_tool.get_voxel(position)
	var newVoxelId = blockUtils.getVariantBlockId(voxelId, rotation, variant, color)
	
	var script = getBlockScript(terrain, position)
	if script:
		var newVoxelItem = blockUtils.list_id2obj[newVoxelId]
		
		script.voxelVariant = blockUtils.getVariantFromVariantAndColor(voxelId, variant, color)
		script.voxelBaseVariant = variant
		script.voxelColorVariant = color
		
		script.voxelBlockId = newVoxelId
		script.voxelBlockItem = newVoxelItem
		
		if newVoxelItem.has("rotation"):
			script.voxelRotation = newVoxelItem.currentRotation
			script.voxelDirection = newVoxelItem.rotation.d
			script.voxelDirectionUp = newVoxelItem.rotation.u
		else:
			script.voxelRotation = 0
			script.voxelDirection = Vector3(1, 0, 0)
			script.voxelDirectionUp = Vector3(0, 1, 0)
	
	loadBlock(terrain, position, newVoxelId)
	
	terrain.voxel_tool.set_voxel(position, newVoxelId)
	saves.changeInteractiveVoxel(terrain, position, newVoxelId)

func setVariantAndColor(terrain, position: Vector3i, variant, color):
	terrain = getTerrain(terrain)
	setRotationAndVariantAndColor(terrain, position, getRotation(terrain, position), variant, color)

func getVariantsCount(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	return obj.baseVariantsCount
	
func getColorsCount(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	return obj.colorVariantsCount
	
func getRotationsCount(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	return obj.rotationsCount
	
func getVariant(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	return obj.baseVariant
	
func getColor(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	return obj.colorVariant
	
func getRotation(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	var obj = getBlockObj(terrain, position)
	return obj.currentRotation
	
func setVariant(terrain, position: Vector3i, variant):
	terrain = getTerrain(terrain)
	setVariantAndColor(terrain, position, variant, getColor(terrain, position))
	
func setColor(terrain, position: Vector3i, color):
	terrain = getTerrain(terrain)
	setVariantAndColor(terrain, position, getVariant(terrain, position), color)
	
func setRotation(terrain, position: Vector3i, rotation):
	terrain = getTerrain(terrain)
	setRotationAndVariantAndColor(terrain, position, rotation, getVariant(terrain, position), getColor(terrain, position))

func setVoxelMetadata(terrain, position: Vector3i, data):
	terrain = getTerrain(terrain)
	if terrain is VoxelTerrain:
		terrain.voxel_tool.set_voxel_metadata(position, data)

func getVoxelMetadata(terrain, position: Vector3i):
	terrain = getTerrain(terrain)
	if terrain is VoxelTerrain:
		return terrain.voxel_tool.get_voxel_metadata(position)
	return null
