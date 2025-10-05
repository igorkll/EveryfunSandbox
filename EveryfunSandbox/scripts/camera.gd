extends Camera3D

var orbitalOffset = 15
var orbitalHeight = 10

var currentYaw = 0.0
var currentPitch = 0.0
var orbital = false
var orbitalValue = 0
var defaultPosition = position
var oldRotation = rotation
var realPosition

var shakeAnimationValue = 0
var shakeAnimationValueDouble = 0

func _input(event):
	if !orbital:
		if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && !orbital:
			var scale = game.getScale()
			var yaw = event.relative.x * scale * game.settings.control.mouse.sensitivity * consts.base_mouse_sensitivity
			var pitch = event.relative.y * scale * game.settings.control.mouse.sensitivity * consts.base_mouse_sensitivity
			cameraUpdate(yaw, pitch)

var _shakeEnd = false
var _shakeEnd2 = false
var isWalking = false
func _process(delta):
	var player = get_parent()
	var interval = consts.step_sprint_interval if player.isSprinting else consts.step_interval
	
	if not player.isWalking:
		isWalking = false
	elif shakeAnimationValue == 0 or shakeAnimationValueDouble == 0:
		isWalking = true
	
	if isWalking or shakeAnimationValue != 0:
		shakeAnimationValue += (delta / interval) * 2
		if shakeAnimationValue > PI * 2:
			shakeAnimationValue = 0
			
	if isWalking or shakeAnimationValueDouble != 0:
		shakeAnimationValueDouble += (delta / interval) * 4
		if shakeAnimationValueDouble > PI * 2:
			shakeAnimationValueDouble = 0
			
	var __shakeEnd = shakeAnimationValue > PI
	var shakeEnd = __shakeEnd and not _shakeEnd
	_shakeEnd = __shakeEnd
	
	var __shakeEnd2 = shakeAnimationValueDouble > PI
	var shakeEnd2 = __shakeEnd2 and not _shakeEnd2
	_shakeEnd2 = __shakeEnd2
	
	if not isWalking:
		if shakeEnd:
			shakeAnimationValue = 0
		
		if shakeEnd2:
			shakeAnimationValueDouble = 0
	
	if orbital:
		orbitalUpdate(delta)
	else:
		var axises = game.getRightJoystickValues()
		var mul = game.settings.control.joystick.sensitivity * delta * consts.base_joystick_camera_sensitivity
		cameraUpdate(axises[0] * mul, axises[1] * mul)

func orbitalUpdate(delta=null):
	position = Vector3(sin(orbitalValue) * orbitalOffset, orbitalHeight, cos(orbitalValue) * orbitalOffset)
	look_at(get_parent().global_transform.origin, Vector3.UP)
	if delta:
		orbitalValue += deg_to_rad(8) * delta;

func cameraUpdate(yaw, pitch):
	currentYaw -= yaw
	currentPitch -= pitch
	currentPitch = clamp(currentPitch, -89, 89) 

	rotation_degrees.y = currentYaw
	rotation_degrees.x = currentPitch
	
	position = defaultPosition + Vector3(sin(shakeAnimationValue) * 0.2, sin(shakeAnimationValueDouble) * 0.2, 0)

func setOrbital(newOrbital):
	orbital = newOrbital
	orbitalValue = 0
	if orbital:
		oldRotation = rotation
		orbitalUpdate()
	else:
		position = defaultPosition
		rotation = oldRotation
		cameraUpdate(0, 0)
