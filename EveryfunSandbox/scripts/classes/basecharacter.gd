extends CharacterBody3D

var character_height

# -------------------------------------------------

var _inited = false

func _physics_process(delta):
	if not _inited || not saves.isWorldFullLoaded():
		return
		
	

# -------------------------------------------------

func _getVoxelWithOffset(side, offset):
	var result = game.terrain.voxel_tool.raycast(
		global_transform.origin + offset,
		side,
		(character_height / 2) + 0.01
	)

	if result:
		return game.terrain.voxel_tool.get_voxel(result.position)

func _getVoxel(side):
	var result = _getVoxelWithOffset(side, Vector3(0, 0, 0))
	if result:
		return result
	
	for x in [-1, 1]:
		for z in [-1, 1]:
			result = _getVoxelWithOffset(side, (Vector3(x, 0, z) * $collision.shape.radius) / sqrt(2))
			if result:
				return result

# ------------------------------------------------- api

func init(collision, mesh):
	add_child(collision)
	
	var meshIntance = MeshInstance3D.new()
	meshIntance.mesh = mesh
	add_child(meshIntance)
	
	character_height = collision.shape.height
	_inited = true

func apply_impulse(direction: Vector3):
	velocity += direction

func getDownVoxel():
	return _getVoxel(Vector3.DOWN)
		
func getDownVoxelObj():
	var voxelId = getDownVoxel()
	if voxelId:
		return blockUtils.list_id2obj[voxelId]
		
func getUpVoxel():
	return _getVoxel(Vector3.UP)
		
func getUpVoxelObj():
	var voxelId = getUpVoxel()
	if voxelId:
		return blockUtils.list_id2obj[voxelId]
