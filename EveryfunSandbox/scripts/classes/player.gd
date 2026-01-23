extends human

var camera

var control_lock = false
var orbital_camera = false

var characterScale = 1.25

var inventoryModal

func _ready():
	super._ready()
	
	if not storageData.has("inventory"):
		storageData.inventory = {maxitems = 2000}
		
	if not storageData.has("selectedItem"):
		storageData.selectedItem = "block_grass_r0_c0_v0"
	
	var hum := characterUtils.createHuman()
	initHuman(hum, characterScale)
	
	camera = preload("res://scripts/classes/playerCamera.gd").new()
	camera.name = "camera"
	camera.fov = 80
	camera.add_child(chunkloader.new())
	cameraContainer.add_child(camera)

func _physics_process(delta):
	if Input.is_action_just_pressed("inventory"):
		if is_instance_valid(inventoryModal) && inventoryModal.visible:
			modalUI.close()
		else:
			inventoryModal = modalUI.inventoryGui("inventory", storageData.inventory, null, onItemSelect)
			
	if not control_lock:
		controlHandler()
	else:
		game.setCrosspiece("normal")
	
	super._physics_process(delta)

func onItemSelect(inventory, itemName):
	storageData.selectedItem = itemName

func controlHandler():
	# ---------------------------------- fly
	
	if saves.currentWorldData.debug.allowFly:
		if not control_lock && (game.is_action_multiple_pressed("jump") || Input.is_action_just_pressed("fly")):
			fly_mode = not fly_mode
		
		if fly_mode:
			disable_collision = saves.currentWorldData.debug.disableCollisionOnFly
	else:
		fly_mode = false
		
	if not fly_mode:
		disable_collision = false
	
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
	beware_edge = false
	fly_down = false
	if Input.is_action_pressed("crouch"):
		beware_edge = true
		if fly_mode:
			fly_down = true
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
			inventoryUtils.destroyBlock(result[0], result[1].position, storageData.inventory)
			
	if Input.is_action_just_pressed("place"):
		if result and terrainUtils.isCellFree(result[0], result[1].previous_position):
			var blockRotation = blockUtils.getTargetRotation(camera.global_transform.basis.z)
			# terrainInteractions.placeBlock(result[0], result[1].previous_position, blockUtils.list_name2id["grammophone"], blockRotation)
			# storageData.selectedItem = "block_grammophone_r2_c0_v0_unique5309745859168615"
			inventoryUtils.placeBlock(result[0], result[1].previous_position, storageData.inventory, storageData.selectedItem, blockRotation)
	
	if Input.is_action_just_pressed("chat"):
		if result:
			if terrainUtils.isDymanic(result[0]):
				terrainUtils.makeStatic(result[0], result[1].position)
			else:
				terrainUtils.makeDynamic(result[0], result[1].position)
	
	if result && terrainUtils.canUseBlock(result[0], result[1].position):
		game.setCrosspiece("use")
		if Input.is_action_just_pressed("use"):
			terrainUtils.useBlock(result[0], result[1].position)
	else:
		game.setCrosspiece("normal")
