extends Camera3D

var orbitalOffset = 15
var orbitalHeight = 10

var amplitude_multiplier = 1
var currentYaw = 0.0
var currentPitch = 0.0
var orbital = false
var orbitalValue = 0
var defaultPosition = position
var oldRotation = rotation
var realPosition

var shakeAnimationValue = 0
var player

func _ready():
	player = get_parent().get_parent()
	currentYaw = player.storageData.get("cameraYaw", 0)
	currentPitch = player.storageData.get("cameraPitch", 0)

func _input(event):
	if !orbital:
		if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && !orbital:
			var scale = game.getScale()
			var yaw = event.relative.x * scale * game.settings.control.mouse.sensitivity * consts.base_mouse_sensitivity
			var pitch = event.relative.y * scale * game.settings.control.mouse.sensitivity * consts.base_mouse_sensitivity
			cameraUpdate(yaw, pitch)

var _shakeEnd = false
var isWalking = false
func _process(delta):
	if not player.inited:
		return
	
	setOrbital(player.orbital_camera)
	
	var interval = player._step_interval
	
	if not player._walking or not player.is_on_floor():
		isWalking = false
	elif shakeAnimationValue == 0:
		isWalking = true
	
	if isWalking or shakeAnimationValue != 0:
		shakeAnimationValue += (delta / interval) * 4
		if shakeAnimationValue > PI * 2:
			shakeAnimationValue = 0
			
	var __shakeEnd = shakeAnimationValue > PI
	var shakeEnd = __shakeEnd and not _shakeEnd
	_shakeEnd = __shakeEnd
	
	if not isWalking:
		if shakeEnd:
			shakeAnimationValue = 0
	
	if orbital:
		orbitalUpdate(delta)
	else:
		var axises = game.getRightJoystickValues()
		var mul = game.settings.control.joystick.sensitivity * delta * consts.base_joystick_camera_sensitivity
		cameraUpdate(axises[0] * mul, axises[1] * mul)
	
	player.storageData.cameraYaw = currentYaw
	player.storageData.cameraPitch = currentPitch
	
	# position = Vector3(0, 0, 5)

func orbitalUpdate(delta=null):
	position = Vector3(sin(orbitalValue) * orbitalOffset, orbitalHeight, cos(orbitalValue) * orbitalOffset)
	look_at(player.global_transform.origin, Vector3.UP)
	if delta:
		orbitalValue += deg_to_rad(8) * delta;

func cameraUpdate(yaw, pitch):
	currentYaw -= yaw
	currentPitch -= pitch
	currentPitch = clamp(currentPitch, -89, 89) 

	player.rotation_degrees.y = currentYaw
	rotation_degrees.x = currentPitch
	
	# position = defaultPosition + funcs.rotateVectorIn_xz(
	# 	Vector3(sin(shakeAnimationValue) * 0.02 * amplitude_multiplier, abs(sin(shakeAnimationValue)) * -0.03 * amplitude_multiplier, 0),
	# 	-currentYaw
 	#)
	position = defaultPosition + Vector3(sin(shakeAnimationValue) * 0.02 * amplitude_multiplier, abs(sin(shakeAnimationValue)) * -0.03 * amplitude_multiplier, 0)

func setOrbital(newOrbital):
	if newOrbital == orbital:
		return
	
	orbital = newOrbital
	orbitalValue = 0
	if orbital:
		oldRotation = rotation
		orbitalUpdate()
	else:
		position = defaultPosition
		rotation = oldRotation
		cameraUpdate(0, 0)
