extends Camera3D

var orbitalOffset = 15
var orbitalHeight = 10

var currentYaw = 0.0
var currentPitch = 0.0
var orbital = false
var orbitalValue = 0
var defaultPosition = position
var oldRotation = rotation

func _input(event):
	if !orbital:
		if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			var scale = game.getScale()
			var yaw = event.relative.x * scale * game.settings.control.mouse.sensitivity * consts.base_mouse_sensitivity
			var pitch = -event.relative.y * scale * game.settings.control.mouse.sensitivity * consts.base_mouse_sensitivity
			cameraUpdate(yaw, pitch)
			
func _process(delta):
	if orbital:
		orbitalUpdate(delta)
	else:
		var axises = game.getRightJoystickValues()
		var mul = game.settings.control.joystick.sensitivity * delta * consts.base_joystick_camera_sensitivity
		cameraUpdate(axises[0] * mul, -axises[1] * mul)

func orbitalUpdate(delta=null):
	position = Vector3(sin(orbitalValue) * orbitalOffset, orbitalHeight, cos(orbitalValue) * orbitalOffset)
	look_at(get_parent().global_transform.origin, Vector3.UP)
	if delta:
		orbitalValue += deg_to_rad(8) * delta;

func cameraUpdate(yaw, pitch):
	currentYaw += yaw
	currentPitch += pitch
	currentPitch = clamp(currentPitch, -90, 90)

	rotation_degrees.y = currentYaw
	rotation_degrees.x = currentPitch

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
