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
	else:
		game.setCrosspiece("normal")
	
	super._physics_process(delta)

func raycast():
	var raycastPosition = camera.get_global_transform().origin
	var raycastDirection = -camera.get_transform().basis.z
	return terrainUtils.blockRaycast(raycastPosition, raycastDirection, consts.max_interact_distance)
