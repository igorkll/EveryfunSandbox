extends human

var camera

var control_lock = false
var orbital_camera = false

func _ready():
	super._ready()
	camera = preload("res://scripts/classes/playerCamera.gd").new()
	camera.name = "camera"
	camera.fov = 80
	camera.add_child(chunkloader.new())
	cameraContainer.add_child(camera)

func _physics_process(delta):
	if not control_lock:
		controlHandler()
	else:
		game.setCrosspiece("normal")
		fly_mode = false
	
	super._physics_process(delta)
	
func controlHandler():
	# ---------------------------------- control handler
	
	if saves.currentWorldData.debug.allowFly:
		if not control_lock && game.is_action_multiple_pressed("jump"):
			fly_mode = not fly_mode
	else:
		fly_mode = false

	var _move_acceleration = move_acceleration
	_step_interval = step_interval
	var direction = Vector3.ZERO	
	isWalking = false
	if not controlLock:
		var joystickWalk = game.getLeftJoystickValues()
		
		if joystickWalk[0] != 0 || joystickWalk[1] != 0:
			direction += Vector3(joystickWalk[0], 0, -joystickWalk[1])
			isWalking = true
		
		if Input.is_action_pressed("move_right"):
			direction.x += 1
			isWalking = true
		
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
			isWalking = true
		
		if Input.is_action_pressed("move_back"):
			direction.z -= 1
			isWalking = true
		
		if Input.is_action_pressed("move_forward"):
			direction.z += 1
			isWalking = true
		
		if Input.is_action_pressed("crouch"):
			if flyState:
				if Input.is_action_pressed("sprint"):
					_move_acceleration *= consts.player_mul_sprint
					_stepInterval /= consts.player_mul_sprint
				velocity.y -= _move_acceleration * delta
			else:
				_move_acceleration *= consts.player_mul_crouch
				_stepInterval /= consts.player_mul_crouch
		elif Input.is_action_pressed("sprint"):
			_move_acceleration *= consts.player_mul_sprint
			_stepInterval /= consts.player_mul_sprint

	if flyState:
		_move_acceleration *= consts.player_mul_fly
		_stepInterval /= consts.player_mul_fly
	
	if isWalking:
		onWalking()
	elif _walk:
		onStopWalk()
	_walk = isWalking
	
	if not controlLock && Input.is_action_pressed("jump") && (flyState || is_on_floor()):
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
		
	# ---------------------------------- edit
	
	var result = raycast()
		
	if Input.is_action_just_pressed("attack"):
		if result:
			terrainInteractions.destroyBlock(result[0], result[1].position)
			
			var body = bodyUtils.createBody(terrainUtils.getGlobalPositionFromVoxelPosition(result[0], result[1].position) + Vector3(0, 15, 0))
			terrainUtils.placeBlock(body, Vector3i(0, 0, 0), blockUtils.list_name2id["testTempScript"])
			
	if Input.is_action_just_pressed("place"):
		if result and terrainUtils.isCellFree(result[0], result[1].previous_position):
			terrainInteractions.placeBlock(result[0], result[1].previous_position, blockUtils.list_name2id["explosive"], blockUtils.getTargetRotation(camera.global_transform.basis.z))
		
	if result && terrainUtils.canUseBlock(result[0], result[1].position):
		game.setCrosspiece("use")
		if Input.is_action_just_pressed("use"):
			terrainUtils.useBlock(result[0], result[1].position)
	else:
		game.setCrosspiece("normal")

func raycast():
	var raycastPosition = camera.get_global_transform().origin
	var raycastDirection = -camera.get_transform().basis.z
	return terrainUtils.blockRaycast(raycastPosition, raycastDirection, consts.max_interact_distance)
