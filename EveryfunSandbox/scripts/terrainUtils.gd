extends Node

func blockRaycast(position, direction, maxDistance):
	var terrain = game.terrain
	
	var result = terrain.voxel_tool.raycast(position, direction, maxDistance)
	if result:
		return [terrain, result]
		
func attachBlockChild(terrain, position, child):
	if not terrain.blockChildren.has(position):
		terrain.blockChildren[position] = []
	terrain.blockChildren[position].append(child)
	terrain.add_child(child)
	
func getBlockChildren(terrain, position):
	if terrain.blockChildren.has(position):
		return terrain.blockChildren[position]
	else:
		return []

func loadBlock(terrain, position: Vector3i, blockId: int, storageData=null):
	if terrain.blockChildren.has(position):
		return
	
	if storageData == null:
		storageData = game.getDefaultStorageData(blockId)
	
	var obj = game.blockList[blockId]
	var childPos = Vector3(position) + Vector3(0.5, 0.5, 0.5)
	
	if obj.has("script"):
		var script = game.loadResource(obj.script)
		var node = script.new()
		
		node.position = childPos
		node.storageData = storageData
		node.scriptData = obj.get("script_data", {})
		
		node.voxelTerrain = terrain
		node.voxelPosition = position
		node.voxelRotation = 0
		node.voxelVariant = obj.currentVariant
		node.voxelBaseVariant = obj.baseVariant
		node.voxelColorVariant = obj.colorVariant
		node.voxelDirection = Vector3i(1, 0, 0)
		node.voxelDirectionUp = Vector3i(0, 1, 0)
		
		node.voxelBaseBlockId = obj.baseId
		node.voxelBaseBlockItem = game.blockList[obj.baseId]
		
		node.voxelBlockId = blockId
		node.voxelBlockItem = obj
		
		node.multiblock = Vector3i(1, 1, 1)
		node.multiblockRelative = node.multiblock
		
		if obj.has("rotation"):
			node.rotation_degrees = obj.rotation.r
			node.voxelRotation = obj.currentRotation
			node.voxelDirection = obj.rotation.d
			node.voxelDirectionUp = obj.rotation.u
		
		attachBlockChild(terrain, position, node)
		
	if obj.has("lights"):
		for lightData in obj.lights:
			var lightObj
			match lightData.type:
				"OmniLight":
					lightObj = OmniLight3D.new()
					lightObj.omni_attenuation = lightData.get("omni_attenuation", lightObj.omni_attenuation)
					lightObj.omni_range = lightData.get("omni_range", lightObj.omni_range)
					lightObj.omni_shadow_mode = lightData.get("omni_shadow_mode", lightObj.omni_shadow_mode)

				"SpotLight":
					lightObj = SpotLight3D.new()
					lightObj.spot_angle = lightData.get("spot_angle", lightObj.spot_angle)
					lightObj.spot_angle_attenuation = lightData.get("spot_angle_attenuation", lightObj.spot_angle_attenuation)
					lightObj.spot_attenuation = lightData.get("spot_attenuation", lightObj.spot_attenuation)
					lightObj.spot_range = lightData.get("spot_range", lightObj.spot_range)
				_:
					print("unknown light type")
					
			lightObj.shadow_enabled = true
			lightObj.light_color = Color(lightData.get("color", "#ffffff"))
			
			lightObj.position = childPos
			attachBlockChild(terrain, position, lightObj)
		
func unloadBlock(terrain, position: Vector3i):
	if terrain.blockChildren.has(position):
		for obj in terrain.blockChildren[position]:
			obj.queue_free()
		terrain.blockChildren.erase(position)

func placeBlock(terrain, position: Vector3i, blockId: int, rotation=0, variant=0, color=0, withSound=true, storageData=null):
	if storageData == null:
		storageData = game.getDefaultStorageData(blockId)
	
	blockId = game.getVariantBlockId(blockId, rotation, variant, color)
	var item = game.blockList[blockId]
	
	terrain.voxel_tool.set_voxel(position, blockId)
	
	if withSound && item.has("sound_place"):
		game.playSound(game.soundList[item.sound_place], getGlobalPositionFromVoxelPosition(terrain, position))
	
	if game.isInteractive(blockId):
		saves.regInteractiveVoxel(terrain, position, blockId, storageData)
	
	if saves.isInteractiveChunkBlockLoaded(position):
		loadBlock(terrain, position, blockId, storageData)

func destroyBlock(terrain, position: Vector3i, withSound=true):
	var obj = game.blockList[terrain.voxel_tool.get_voxel(position)]
	if withSound && obj.has("sound_destroy"):
		game.playSound(game.soundList[obj.sound_destroy], getGlobalPositionFromVoxelPosition(terrain, position))
	
	unloadBlock(terrain, position)
	saves.regInteractiveVoxel(terrain, position, null)
	
	terrain.voxel_tool.set_voxel(position, 0)

func callBlock(terrain, position: Vector3i, method, ...args) -> bool:
	var children = getBlockChildren(terrain, position)
	var result = false
	for child in children:
		if child.has_method(method):
			if child.callv(method, args):
				result = true
	return result

func useBlock(terrain, position: Vector3i) -> bool:
	var children = getBlockChildren(terrain, position)
	var used = false
	for child in children:
		if child.has_method("_use"):
			child.call("_use")
			used = true
	return used
	
func canUseBlock(terrain, position: Vector3i) -> bool:
	var children = getBlockChildren(terrain, position)
	for child in children:
		if child.has_method("_use"):
			return true
	return false

func getVoxelPositionFromGlobalPosition(terrain, position: Vector3) -> Vector3i:
	return funcs.vec3_to_vec3i_down(position - terrain.global_transform.origin)

func getGlobalPositionFromVoxelPosition(terrain, position: Vector3i) -> Vector3:
	return terrain.global_transform.origin + Vector3(position.x, position.y, position.z) + Vector3(0.5, 0.5, 0.5)

func isCellFree(terrain, position: Vector3i) -> bool:
	if terrain.voxel_tool.get_voxel(position) != 0:
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
