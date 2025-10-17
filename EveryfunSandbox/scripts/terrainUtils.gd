extends Node

func blockRaycast(position, direction, maxDistance):
	var terrain = game.terrain
	
	var result = terrain.voxel_tool.raycast(position, direction, maxDistance)
	if result:
		return [terrain, result]
		
func attachBlockChild(position, child):
	var terrain = game.terrain
	
	if not terrain.blockChildren.has(position):
		terrain.blockChildren[position] = []
	terrain.blockChildren[position].append(child)
	terrain.add_child(child)
	
func getBlockChildren(position):
	var terrain = game.terrain
	
	if terrain.blockChildren.has(position):
		return terrain.blockChildren[position]
	else:
		return []

func loadBlock(position: Vector3i, blockId: int, storageData=null) -> bool:
	var terrain = game.terrain
	
	if terrain.blockChildren.has(position):
		return false
	
	if storageData == null:
		storageData = {}
	
	var obj = game.blockList[blockId]
	var childPos = Vector3(position) + Vector3(0.5, 0.5, 0.5)
	
	var isInteractive = false
	
	if obj.has("script"):
		var script = game.loadResource(obj.script)
		var node = script.new()
		
		node.position = childPos
		node.storageData = storageData
		
		node.voxelPosition = position
		node.voxelDirection = Vector3i(1, 0, 0)
		node.voxelDirectionUp = Vector3i(0, 1, 0)
		
		node.multiblock = Vector3i(1, 1, 1)
		node.multiblockRelative = node.multiblock
		
		if obj.has("rotation"):
			node.rotation_degrees = obj.rotation.r
			node.voxelDirection = obj.rotation.d
			node.voxelDirectionUp = obj.rotation.u
		
		attachBlockChild(position, node)
		isInteractive = true
		
	return isInteractive
		
func unloadBlock(position: Vector3i):
	var terrain = game.terrain
	
	if terrain.blockChildren.has(position):
		for obj in terrain.blockChildren[position]:
			obj.queue_free()
		terrain.blockChildren.erase(position)

func placeBlock(position: Vector3i, blockId: int, rotation=0, withSound=true, storageData=null):
	var terrain = game.terrain
	
	if storageData == null:
		storageData = {}
	
	var obj = game.blockList[blockId]
	if obj.has("rotated"):
		rotation = (int(rotation + obj.get("rotationBase", 0)) % 4) + (floor(rotation / 4) * 4)
		blockId = obj.rotated[rotation % obj.rotated.size()].id
		obj = game.blockList[blockId]
	
	terrain.voxel_tool.set_voxel(position, blockId)
	
	if withSound && obj.has("sound_place"):
		game.playSound(game.soundList[obj.sound_place], getGlobalPositionFromVoxelPosition(position))
	
	var isInteractive = loadBlock(position, blockId, storageData)
	if isInteractive:
		if terrain == game.terrain:
			saves.regInteractiveVoxel(position, blockId, storageData)
	
		
func destroyBlock(position: Vector3i, withSound=true):
	var terrain = game.terrain
	
	var obj = game.blockList[terrain.voxel_tool.get_voxel(position)]
	if withSound && obj.has("sound_destroy"):
		game.playSound(game.soundList[obj.sound_destroy], getGlobalPositionFromVoxelPosition(position))
	
	unloadBlock(position)
	if terrain == game.terrain:
		saves.regInteractiveVoxel(position, null)
	
	terrain.voxel_tool.set_voxel(position, 0)

func useBlock(position: Vector3i) -> bool:
	var children = getBlockChildren(position)
	var used = false
	for child in children:
		if child.has_method("_use"):
			child.call("_use")
			used = true
	return used
	
func canUseBlock(position: Vector3i) -> bool:
	var children = getBlockChildren(position)
	for child in children:
		if child.has_method("_use"):
			return true
	return false

func getVoxelPositionFromGlobalPosition(position: Vector3) -> Vector3i:
	var terrain = game.terrain
	
	return funcs.vec3_to_vec3i_down(position - terrain.global_transform.origin)

func getGlobalPositionFromVoxelPosition(position: Vector3i) -> Vector3:
	var terrain = game.terrain
	
	return terrain.global_transform.origin + Vector3(position.x, position.y, position.z) + Vector3(0.5, 0.5, 0.5)

func isCellFree(position: Vector3i) -> bool:
	var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.8, 0.8, 0.8)
	query.shape = shape
	query.transform = Transform3D(Basis(), getGlobalPositionFromVoxelPosition(position))
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var results = space_state.intersect_shape(query)
	return results.size() == 0
