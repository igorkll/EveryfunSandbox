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
	# ---------------------------------- fly
	
	if saves.currentWorldData.debug.allowFly:
		if not control_lock && game.is_action_multiple_pressed("jump"):
			fly_mode = not fly_mode
	else:
		fly_mode = false
		
	# ---------------------------------- direction
	
	jump_state = Input.is_action_pressed("jump")
	
	var direction = Vector3.ZERO
	var joystickWalk = game.getLeftJoystickValues()
	
	if joystickWalk[0] != 0 || joystickWalk[1] != 0:
		direction += Vector3(joystickWalk[0], 0, -joystickWalk[1])
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
		
	self.direction = direction.normalized()
	
	# ---------------------------------- speed
	
	walking_speed_mul = 1
	if Input.is_action_pressed("crouch"):
		if fly_mode:
			if Input.is_action_pressed("sprint"):
				walking_speed_mul = consts.player_mul_sprint
		else:
			walking_speed_mul = consts.player_mul_crouch
	elif Input.is_action_pressed("sprint"):
		walking_speed_mul = consts.player_mul_sprint
	
	camera.amplitude_multiplier = walking_speed_mul
	
	if fly_mode:
		walking_speed_mul *= consts.player_mul_fly
		
	# ---------------------------------- interact
	
	var result = raycast(camera)
	
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
