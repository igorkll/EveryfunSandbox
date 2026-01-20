extends CharacterBody3D
class_name basecharacter

var id: int
var inited = false
var nonUnloadable = false
var storageData = {}

var character_radius = 1
var character_height = 1

var disable_collision = false
var disable_collision_sounds = false

var direction = Vector3.ZERO
var jump_state = false
var fly_mode = false
var fly_down = false
var beware_edge = false

var move_acceleration = 30
var jump_acceleration = 8
var fall_speed_mul = 2.5
var step_interval = 0.4
var velocity_drop = 0.0005
var push_strength = 1

var walking_speed_mul = 1
var velocity_drop_mul = 1

# -------------------------------------------------

var _collision: CollisionShape3D

var _headbutt_sound_available = false
var _on_floor = false
var _current_jump = false
var _walking = false
var _jump_allow = true

var _move_acceleration
var _step_interval

func _physics_process(delta):
	if not inited || not saves.isWorldFullLoaded():
		return
	
	_collision.disabled = disable_collision
	_move_acceleration = move_acceleration * walking_speed_mul
	_step_interval = step_interval / walking_speed_mul
	
	var player_basis = global_transform.basis
	var player_direction = -player_basis.z
	var player_right = player_basis.x.normalized()
	
	player_direction.y = 0
	player_direction = player_direction.normalized()
	
	var is_walking = direction != Vector3.ZERO
	if is_walking:
		_onWalking()
	elif _walking:
		_onStopWalk()
	_walking = is_walking
	
	var move_direction = (player_direction * direction.z + player_right * direction.x)
	move_direction.y = 0
	
	if move_direction.length() > 1:
		move_direction = move_direction.normalized()
	
	var on_floor = is_on_floor()
	if beware_edge && on_floor:
		var edges = getEdgeDirections()
		for edge in edges:
			var project = move_direction.project(edge)
			if funcs.compareMark(edge.x, project.x) and funcs.compareMark(edge.z, project.z):
				move_direction = move_direction - project

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	if not on_floor:
		if not fly_mode:
			velocity += get_gravity() * delta * fall_speed_mul
	elif not _on_floor:
		var voxel = getDownVoxelObj()
		if voxel and voxel.has("sound_jump") and game.soundList.has(voxel.sound_jump):
			_blockSound(game.soundList[voxel.sound_jump])
	_on_floor = on_floor
	
	if fly_mode && fly_down:
		velocity.y -= _move_acceleration * delta
	
	if jump_state:
		if fly_mode:
			velocity.y += _move_acceleration * delta
		elif on_floor && _jump_allow:
			velocity.y += jump_acceleration
			_jump_allow = false
	else:
		_jump_allow = true
		
	if velocity.y > 0:
		var voxel = getUpVoxelObj()
		if voxel and voxel.has("sound_headbutt") and game.soundList.has(voxel.sound_headbutt) and _headbutt_sound_available:
			_blockSound(game.soundList[voxel.sound_headbutt])
			_headbutt_sound_available = false
	elif velocity.y < 0:
		_headbutt_sound_available = true
	
	var voxel_velocity_drop_mul = 1
	var speed_mul = pow(velocity_drop * velocity_drop_mul * voxel_velocity_drop_mul, delta);
	velocity.x *= speed_mul;
	if fly_mode:
		velocity.y *= speed_mul;
	velocity.z *= speed_mul;
	
	if terrainUtils.isMinimalAreaLoaded(game.terrain, terrainUtils.getVoxelPositionFromGlobalPosition(game.terrain, position)):
		move_and_slide()
		if push_strength:
			_pushObjects()
			
	if not nonUnloadable and not saves.isInteractiveChunkLoadedFull(position):
		characterUtils.unloadCharacter(self)
		
func _pushObjects():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			collider.apply_impulse(push_dir * push_strength, collision.get_position() - collider.global_position)

# -------------------------------------------------

var _walkSoundTimer
var _walkVoxelId
var _currentWalkSound

func _stopWalkTimer():
	if _walkSoundTimer is Timer:
		_blockSound(_currentWalkSound)
	if _walkSoundTimer:
		_walkSoundTimer.queue_free()
		_walkSoundTimer = null
	_walkVoxelId = null
	_currentWalkSound = null

func _onWalking():
	var voxelId = getDownVoxel()
	if voxelId:
		var voxel = blockUtils.list_id2obj[voxelId]
		if voxel and voxel.has("sound_walking") and game.soundList.has(voxel.sound_walking):
			var sound = game.soundList[voxel.sound_walking]
			
			if sound && (not _walkSoundTimer || _walkVoxelId != voxelId):
				_stopWalkTimer()
				_walkVoxelId = voxelId
				
				_walkSoundTimer = Timer.new()
				_walkSoundTimer.wait_time = _step_interval / 2
				_walkSoundTimer.one_shot = true
				_walkSoundTimer.timeout.connect(func(): 
					_walkSoundTimer.queue_free()
					_walkSoundTimer = RandomIntervalTimer.new()
					add_child(_walkSoundTimer)
					
					_walkSoundTimer.interval = sound.get("interval", _step_interval)
					_walkSoundTimer.random_interval = 0.05
					
					_walkSoundTimer.start(_blockSound.bind(sound))
					_blockSound(sound)
				)
				add_child(_walkSoundTimer)
				_walkSoundTimer.start()
				
				_currentWalkSound = sound
	else:
		_stopWalkTimer()
	
	if _walkSoundTimer and _walkSoundTimer is RandomIntervalTimer:
		_walkSoundTimer.interval = _currentWalkSound.get("interval", _step_interval)

func _onStopWalk():
	_stopWalkTimer()

func _blockSound(sound):
	if disable_collision || disable_collision_sounds:
		return
	game.playSound(sound, global_transform.origin - Vector3(0, character_height / 2, 0))
	
# -------------------------------------------------

func _getVoxelWithOffset(side, offset):
	var result = terrainUtils.blockRaycast(
		global_transform.origin + offset,
		side,
		(character_height / 2) + 0.01
	)

	if result:
		return result[0].voxel_tool.get_voxel(result[1].position)

func _getVoxel(side):
	var result = _getVoxelWithOffset(side, Vector3(0, 0, 0))
	if result:
		return result
	
	for x in [-1, 1]:
		for z in [-1, 1]:
			result = _getVoxelWithOffset(side, (Vector3(x, 0, z) * character_radius) / sqrt(2))
			if result:
				return result
				
func _checkEdge(x, z):
	return not _getVoxelWithOffset(Vector3.DOWN, Vector3(x, 0, z) * character_radius)

# ------------------------------------------------- api

func initCharacter(collision: CollisionShape3D, mesh=null, parentCharacter=null):
	if not collision:
		var shape = CapsuleShape3D.new()
		shape.radius = character_radius
		shape.height = character_height
		
		collision = CollisionShape3D.new()
		collision.shape = shape
	
	_collision = collision
	
	add_child(collision)
	
	if mesh:
		var meshIntance = MeshInstance3D.new()
		meshIntance.mesh = mesh
		add_child(meshIntance)
	
	if parentCharacter:
		for shape in parentCharacter.get_children():
			if shape is CollisionShape3D:
				shape.disabled = true
		add_child(parentCharacter)
	
	inited = true

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
		
func getEdgeDirections():
	var edges = []
	
	if _checkEdge(1, 0):
		edges.append(Vector3(1, 0, 0))
		
	if _checkEdge(-1, 0):
		edges.append(Vector3(-1, 0, 0))
		
	if _checkEdge(0, 1):
		edges.append(Vector3(0, 0, 1))
		
	if _checkEdge(0, -1):
		edges.append(Vector3(0, 0, -1))
		
	return edges

func raycast(camera: Camera3D, max_interact_distance=consts.max_interact_distance):
	var global_transform = camera.get_global_transform()
	return terrainUtils.blockRaycast(global_transform.origin, -global_transform.basis.z, max_interact_distance)

func apply_impulse(direction: Vector3, pos=null):
	velocity += direction
