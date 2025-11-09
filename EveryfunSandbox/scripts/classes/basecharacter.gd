extends CharacterBody3D

var character_height

# -------------------------------------------------

var _inited = false
var _collision: CollisionShape3D
var _disable_collision = false
var _direction = Vector3.ZERO

func _physics_process(delta):
	if not _inited || not saves.isWorldFullLoaded():
		return
	
	_collision.disabled = _disable_collision
	
	var player_basis = global_transform.basis
	var player_direction = -player_basis.z
	var player_right = player_basis.x.normalized()
	
	player_direction.y = 0
	player_direction = player_direction.normalized()
	
	var move_direction = (player_direction * _direction.z + player_right * _direction.x)
	move_direction.y = 0
	
	if move_direction.length() > 1:
		move_direction = move_direction.normalized()

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	var on_floor = is_on_floor()
	if not on_floor:
		if not flyState:
			velocity += get_gravity() * delta * fall_speed_mul
	elif not _on_floor:
		var voxel = getDownVoxelObj()
		if voxel and voxel.has("sound_jump") and game.soundList.has(voxel.sound_jump):
			blockSound(game.soundList[voxel.sound_jump])
			
	_on_floor = on_floor

	if current_jump:
		if flyState:
			velocity.y += _move_acceleration * delta
		else:
			velocity.y += jump_acceleration
		
	if velocity.y > 0:
		var voxel = getUpVoxelObj()
		if voxel and voxel.has("sound_headbutt") and game.soundList.has(voxel.sound_headbutt) and headbuttSound:
			blockSound(game.soundList[voxel.sound_headbutt])
			headbuttSound = false
	elif velocity.y < 0:
		headbuttSound = true
	
	var speed_mul = pow(velocity_drop, delta);
	velocity.x *= speed_mul;
	if flyState:
		velocity.y *= speed_mul;
	velocity.z *= speed_mul;
		
	if not terrainUtils.isMinimalAreaLoaded(game.terrain, terrainUtils.getVoxelPositionFromGlobalPosition(game.terrain, position)):
		velocity = Vector3(0, 0, 0)
	
	move_and_slide()

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

func init(collision: CollisionShape3D, mesh: Mesh):
	_collision = collision
	
	add_child(collision)
	
	var meshIntance = MeshInstance3D.new()
	meshIntance.mesh = mesh
	add_child(meshIntance)
	
	character_height = collision.shape.height
	_inited = true

func apply_impulse(direction: Vector3):
	velocity += direction
	
func setDisableCollision(disable_collision: bool):
	_disable_collision = disable_collision

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
