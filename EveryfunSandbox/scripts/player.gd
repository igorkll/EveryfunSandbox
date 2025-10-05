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

var controlLock = false
var _walk = false
var _on_floor = false

var playerData
var inited = false

var halfPlayerSize
var defaultPlayerPosition = position
var isWalking = false
var isSprinting = false

func _ready():
	halfPlayerSize = $collision.shape.height / 2
	pass

func checkOptimalSpawnPosition(raycastPosition) -> bool:
	var result = game.terrain.voxel_tool.raycast(raycastPosition, Vector3.DOWN, 2000)
	print("try", raycastPosition)
	if result:
		print("OPTIMAL", result.previous_position)
		position = game.getGlobalPositionFromVoxelPosition(result.previous_position + Vector3i(0, halfPlayerSize + consts.player_spawn_vertical_offset, 0))
		return true
	return false

func findOptimalSpawnPosition():
	var raycastPosition = $camera.get_global_transform().origin
	raycastPosition.y = 1000
	
	var positionFinded = false
	if checkOptimalSpawnPosition(raycastPosition):
		positionFinded = true
	else:
		for x in range(-1000, 1000, 10):
			if checkOptimalSpawnPosition(raycastPosition + Vector3(x, 0, 0)):
				positionFinded = true
				break
		
		if not positionFinded:
			for z in range(-1000, 1000, 10):
				if checkOptimalSpawnPosition(raycastPosition + Vector3(0, 0, z)):
					positionFinded = true
					break
	
	if not positionFinded:
		position = defaultPlayerPosition

var findOptimalSpawnPositionTimer

func init():
	currentPlayerData = findPlayerData()
	if currentPlayerData.has("position"):
		position = currentPlayerData.position + Vector3(0, consts.player_spawn_vertical_offset, 0)
	else:
		findOptimalSpawnPositionTimer = timers.setInterval(func():
			findOptimalSpawnPosition()
		, 1)
	inited = true
	
	

func _physics_process(delta):
	if not inited || not saves.isWorldFullLoaded():
		return
	
	if findOptimalSpawnPositionTimer:
		timers.clearTimeout(findOptimalSpawnPositionTimer)
		findOptimalSpawnPositionTimer = null
	
	# ---------------------------------- moving control

	var _move_acceleration = move_acceleration
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
		
		isSprinting = Input.is_action_pressed("sprint")
		if isSprinting:
			_move_acceleration *= sprint_mul
	else:
		isSprinting = false
	
	if isWalking:
		onWalking()
	elif _walk:
		onStopWalk()
	_walk = isWalking
	
	if not controlLock && Input.is_action_pressed("jump") && is_on_floor():
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
		saves.save()
		
	# ---------------------------------- edit
	
	if not controlLock:
		if Input.is_action_just_pressed("attack"):
			var result = game.terrain.voxel_tool.raycast($camera.get_global_transform().origin, -$camera.get_transform().basis.z, max_interact_distance)
			if result:
				game.destroyBlock(result.position)
				
		if Input.is_action_just_pressed("place"):
			var result = game.terrain.voxel_tool.raycast($camera.get_global_transform().origin, -$camera.get_transform().basis.z, max_interact_distance)
			if result and game.isCellFree(result.previous_position):
				game.placeBlock(result.previous_position, "stone")
	
	# ---------------------------------- moving
	
	var camera_basis = $camera.global_transform.basis
	var camera_direction = -camera_basis.z
	var camera_right = camera_basis.x.normalized()
	
	camera_direction.y = 0
	camera_direction = camera_direction.normalized()
	
	var move_direction = (camera_direction * direction.z + camera_right * direction.x)
	move_direction.y = 0
	
	if move_direction.length() > 1:
		move_direction = move_direction.normalized()

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	var on_floor = is_on_floor()
	if not on_floor:
		velocity += get_gravity() * delta * fall_speed_mul
	elif not _on_floor:
		var voxel = getDownVoxelObj()
		if voxel and voxel.has("sound_jump") and game.soundList.has(voxel.sound_jump):
			blockSound(game.soundList[voxel.sound_jump])
			
	_on_floor = on_floor

	if current_jump:
		velocity.y += jump_acceleration
	
	var speed_mul = pow(velocity_drop, delta);
	velocity.x *= speed_mul;
	velocity.z *= speed_mul;
	
	move_and_slide()
	
	# ---------------------------------- update data
	
	currentPlayerData.position = position

var walkSoundTimer
var walkVoxelId
var currentWalkSound

func stopWalkTimer():
	if walkSoundTimer is Timer:
		blockSound(currentWalkSound)
	if walkSoundTimer:
		walkSoundTimer.queue_free()
		walkSoundTimer = null
	walkVoxelId = null
	currentWalkSound = null

func onWalking():
	var defaultInterval
	var defaultRandomInterval
	if Input.is_action_pressed("sprint"):
		defaultInterval = consts.step_sprint_interval
		defaultRandomInterval = 0.025
	else:
		defaultInterval = consts.step_interval
		defaultRandomInterval = 0.05

	var voxelId = getDownVoxel()
	if voxelId:
		var voxel = game.blockList[voxelId]
		if voxel and voxel.has("sound_walking") and game.soundList.has(voxel.sound_walking):
			var sound = game.soundList[voxel.sound_walking]
			
			if sound && (not walkSoundTimer || walkVoxelId != voxelId):
				stopWalkTimer()
				walkVoxelId = voxelId
				
				walkSoundTimer = Timer.new()
				walkSoundTimer.wait_time = defaultInterval / 2
				walkSoundTimer.one_shot = true
				walkSoundTimer.timeout.connect(func(): 
					walkSoundTimer.queue_free()
					walkSoundTimer = RandomIntervalTimer.new()
					add_child(walkSoundTimer)
					
					walkSoundTimer.interval = sound.get("interval", defaultInterval)
					walkSoundTimer.random_interval = sound.get("random_interval", defaultRandomInterval)
					
					walkSoundTimer.start(blockSound.bind(sound))
					blockSound(sound)
				)
				add_child(walkSoundTimer)
				walkSoundTimer.start()
				
				currentWalkSound = sound
	else:
		stopWalkTimer()
				
	if walkSoundTimer and walkSoundTimer is RandomIntervalTimer:
		walkSoundTimer.interval = currentWalkSound.get("interval", defaultInterval)
		walkSoundTimer.random_interval = currentWalkSound.get("random_interval", defaultRandomInterval)

func onStopWalk():
	stopWalkTimer()

func blockSound(sound):
	game.playSound(sound, global_transform.origin + Vector3(0, halfPlayerSize, 0))

func _getVoxelWithOffset(side, offset):
	var result = game.terrain.voxel_tool.raycast(
		global_transform.origin + offset,
		side,
		halfPlayerSize + 0.01
	)

	if result:
		return game.terrain.voxel_tool.get_voxel(result.position)

func _getVoxel(side):
	var result = _getVoxelWithOffset(side, Vector3(0, 0, 0))
	if result:
		return result
	
	for x in [-1, 1]:
		for z in [-1, 1]:
			result = _getVoxelWithOffset(side, Vector3(x, 0, z) * ($collision.shape.radius * sqrt(2)))
			if result:
				return result

# ------------------------------------------------- api

var currentPlayerData
var defaultPlayerData = {}

func getNickname():
	return "host"

func getUniqueId():
	return "host"

func findPlayerData():
	var id = getUniqueId()
	if not saves.currentWorldData.playersData.has(id):
		saves.currentWorldData.playersData[id] = {}
	saves.currentWorldData.playersData[id] = funcs.merge_dicts(saves.currentWorldData.playersData[id], defaultPlayerData)
	return saves.currentWorldData.playersData[id]

func getDownVoxel():
	return _getVoxel(Vector3.DOWN)
		
func getDownVoxelObj():
	var voxelId = getDownVoxel()
	if voxelId:
		return game.blockList[voxelId]
		
func getUpVoxel():
	return _getVoxel(Vector3.UP)
		
func getUpVoxelObj():
	var voxelId = getUpVoxel()
	if voxelId:
		return game.blockList[voxelId]

func setControlLock(newControlLock):
	controlLock = newControlLock
