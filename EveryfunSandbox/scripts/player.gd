extends CharacterBody3D

var sprint_mul = 2

var move_acceleration = 30
var jump_acceleration = 8
var fall_speed_mul = 2.5

var velocity_drop = 0.0005
var jump_budget = 0.02

var max_interact_distance = 10

var current_jump = false
var current_jump_budget = 0

var voxel_tool

func _ready():
	voxel_tool = game.terrain.get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	
	position = (Vector3) (0, 50, 0)

var _walk = false

func _physics_process(delta):
	# ---------------------------------- moving control

	var _move_acceleration = move_acceleration
	if Input.is_action_pressed("sprint"):
		_move_acceleration *= sprint_mul

	var direction = Vector3.ZERO	
	var walk = false
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		walk = true
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
		walk = true
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
		walk = true
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
		walk = true
	
	if walk:
		onWalking()
	elif _walk:
		onStopWalk()
	_walk = walk
	
	if Input.is_action_pressed("jump") && is_on_floor():
		if not current_jump:
			current_jump_budget = jump_budget
		current_jump = true
		
	if current_jump:
		current_jump_budget -= delta
		if current_jump_budget < 0:
			current_jump = false
			current_jump_budget = 0
	
	if Input.is_action_just_released("jump"):
		current_jump = false
		current_jump_budget = 0
		
	# ---------------------------------- edit
	
	if Input.is_action_just_pressed("attack"):
		var result = voxel_tool.raycast($camera.get_global_transform().origin, -$camera.get_transform().basis.z, max_interact_distance)
		if result:
			voxel_tool.set_voxel(result.position, 0)
			
	if Input.is_action_just_pressed("place"):
		var result = voxel_tool.raycast($camera.get_global_transform().origin, -$camera.get_transform().basis.z, max_interact_distance)
		if result:
			voxel_tool.set_voxel(result.previous_position, 2)
	
	# ---------------------------------- moving
	
	var camera_basis = $camera.global_transform.basis
	var camera_direction = -camera_basis.z.normalized()
	var camera_right = camera_basis.x.normalized()
	var move_direction = (camera_direction * direction.z + camera_right * direction.x).normalized()
	move_direction.y = 0
	move_direction = move_direction.normalized()

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	if not is_on_floor():
		velocity += get_gravity() * delta * fall_speed_mul

	if current_jump:
		velocity.y += jump_acceleration
	
	var speed_mul = pow(velocity_drop, delta);
	velocity.x *= speed_mul;
	velocity.z *= speed_mul;
	
	move_and_slide()

var walkSoundTimer
var walkVoxelId

func stopWalkTimer():
	if walkSoundTimer:
		walkSoundTimer.queue_free()
		walkSoundTimer = null
	walkVoxelId = null

func onWalking():
	var result = voxel_tool.raycast(
		global_transform.origin,
		Vector3.DOWN,
		($collision.shape.height / 2) + 0.1
	)

	if result:
		var voxelId = voxel_tool.get_voxel(result.position)
		var voxel = game.blockList[voxelId]
		if voxel and voxel.has("walking_sound") and game.soundList.has(voxel.walking_sound):
			var sound = game.soundList[voxel.walking_sound]
			
			if not walkSoundTimer || walkVoxelId != voxelId:
				stopWalkTimer()
				walkVoxelId = voxelId
				
				walkSoundTimer = RandomIntervalTimer.new()
				add_child(walkSoundTimer)
				
				walkSoundTimer.interval = sound.get("interval", 1)
				walkSoundTimer.random_interval = sound.get("random_interval", 0)
				
				walkSoundTimer.start(walkSound.bind(sound))

func onStopWalk():
	stopWalkTimer()
	
func walkSound(sound):
	game.playSound(sound, global_transform.origin + Vector3(0, $collision.shape.height / 2, 0))
