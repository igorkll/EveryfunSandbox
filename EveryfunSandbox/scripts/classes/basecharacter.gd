extends CharacterBody3D

var character_height

var disable_collision = false
var disable_collision_sounds = false
var fly_mode = false
var direction = Vector3.ZERO

var move_acceleration = 30
var jump_acceleration = 8
var fall_speed_mul = 2.5
var step_interval = 0.4

var velocity_drop = 0.0005
var jump_budget = 0.02

var walking_speed_multiplier = 1

# -------------------------------------------------

var _inited = false
var _collision: CollisionShape3D

var _headbutt_sound = false
var _on_floor = false
var _current_jump = false
var _walking = false

var _move_acceleration
var _step_interval

func _physics_process(delta):
	if not _inited || not saves.isWorldFullLoaded():
		return
	
	_collision.disabled = disable_collision
	_move_acceleration = move_acceleration * walking_speed_multiplier
	_step_interval = step_interval * walking_speed_multiplier
	
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

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	var on_floor = is_on_floor()
	if not on_floor:
		if not fly_mode:
			velocity += get_gravity() * delta * fall_speed_mul
	elif not _on_floor:
		var voxel = getDownVoxelObj()
		if voxel and voxel.has("sound_jump") and game.soundList.has(voxel.sound_jump):
			_blockSound(game.soundList[voxel.sound_jump])
	_on_floor = on_floor

	if _current_jump:
		if fly_mode:
			velocity.y += _move_acceleration * delta
		else:
			velocity.y += jump_acceleration
			_current_jump = false
		
	if velocity.y > 0:
		var voxel = getUpVoxelObj()
		if voxel and voxel.has("sound_headbutt") and game.soundList.has(voxel.sound_headbutt) and _headbutt_sound:
			_blockSound(game.soundList[voxel.sound_headbutt])
			_headbutt_sound = false
	elif velocity.y < 0:
		_headbutt_sound = true
	
	var speed_mul = pow(velocity_drop, delta);
	velocity.x *= speed_mul;
	if fly_mode:
		velocity.y *= speed_mul;
	velocity.z *= speed_mul;
		
	if not terrainUtils.isMinimalAreaLoaded(game.terrain, terrainUtils.getVoxelPositionFromGlobalPosition(game.terrain, position)):
		velocity = Vector3(0, 0, 0)
	
	move_and_slide()

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
	
func setJump(jump):
	if jump == null:
		jump = true
	_current_jump = jump

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
		
func apply_impulse(direction: Vector3):
	velocity += direction
