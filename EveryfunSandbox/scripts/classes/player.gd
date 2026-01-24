extends human

var camera

var control_lock = false
var orbital_camera = false

var characterScale = 1.25

var inventoryModal
var hitInfo = {}

func _ready():
	super._ready()
	
	if not storageData.has("inventory"):
		storageData.inventory = {maxitems = 2000}
		
	if not storageData.has("selectedItem"):
		storageData.selectedItem = "block_grass_r0_c0_v0"
	updateSelectedItem()
	
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
		controlHandler(delta)
	else:
		game.setCrosspiece("normal")
	
	super._physics_process(delta)

func updateSelectedItem():
	funcs.ui_clean(game.mainNode, "selectedItemContainer")
	
	var inventoryItem = modalUI.inventoryItemScene.instantiate()
	
	if inventoryUtils.isItemUnknown(storageData.inventory, storageData.selectedItem):
		funcs.ui_set_text(inventoryItem, "name", "unknown item")
	else:
		var name = inventoryUtils.getItemUiName(storageData.inventory, storageData.selectedItem)
		var count = inventoryUtils.getItemsCount(storageData.inventory, storageData.selectedItem)
		if count > 1:
			name += " x" + str(count)
		elif count <= 0:
			name += " (nothing)"
		funcs.ui_set_text(inventoryItem, "name", name)
		
	var icon = inventoryUtils.getItemUiIcon(storageData.inventory, storageData.selectedItem)
	if icon:
		funcs.ui_get_item(inventoryItem, "icon").texture_normal = icon
	
	if inventoryUtils.isUniqueItem(storageData.inventory, storageData.selectedItem):
		funcs.paint_panel(inventoryItem, consts.uniqueItemColor)
		
	funcs.ui_hide(inventoryItem, "transferButton")
	funcs.ui_hide(inventoryItem, "transferHalfButton")
	funcs.ui_hide(inventoryItem, "transferAllButton")
	funcs.ui_hide(inventoryItem, "selectButton")
	
	funcs.ui_append(game.mainNode, "selectedItemContainer", inventoryItem)

func onItemSelect(inventory, itemName):
	storageData.selectedItem = itemName
	updateSelectedItem()

func controlHandler(delta):
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
	
	if Input.is_action_pressed("attack"):
		if result:
			if terrainInteractions.hitBlock(result[0], result[1].position, hitInfo, delta):
				inventoryUtils.destroyBlock(result[0], result[1].position, storageData.inventory)
				updateSelectedItem()
	else:
		terrainInteractions.hitCheck(hitInfo, delta)
			
	if Input.is_action_just_pressed("place"):
		# storageData.inventory.erase("items")
		# inventoryUtils.nonGameCreateItems(storageData.inventory, "block_crafting_table_r0_c0_v0", 10)
		if result and terrainUtils.isCellFree(result[0], result[1].previous_position):
			if inventoryUtils.isBlockItem(storageData.inventory, storageData.selectedItem):
				var blockRotation = blockUtils.getTargetRotation(camera.global_transform.basis.z)
				inventoryUtils.placeBlock(result[0], result[1].previous_position, storageData.inventory, storageData.selectedItem, blockRotation)
				updateSelectedItem()
	
	if Input.is_action_just_pressed("chat"):
		if result:
			if terrainUtils.isDymanic(result[0]):
				terrainUtils.makeStatic(result[0], result[1].position)
			else:
				terrainUtils.makeDynamic(result[0], result[1].position)
	
	if result && terrainUtils.canUseBlock(result[0], result[1].position):
		game.setCrosspiece("use")
		if Input.is_action_just_pressed("use"):
			terrainUtils.useBlock(result[0], result[1].position, self)
	else:
		game.setCrosspiece("normal")
