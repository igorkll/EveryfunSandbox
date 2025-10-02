extends Camera3D

var sensitivity = 0.2
var orbitalOffset = 15
var orbitalHeight = 10

var total_pitch = 0.0
var orbital = false
var orbitalValue = 0

func _input(event):
	if !orbital:
		if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			var yaw = event.relative.x * sensitivity
			var pitch = event.relative.y * sensitivity
			cameraUpdate(yaw, pitch)
			
func _physics_process(delta):
	if orbital:
		orbitalUpdate(delta)
		
func orbitalUpdate(delta=null):
	position = Vector3(sin(orbitalValue) * orbitalOffset, orbitalHeight, cos(orbitalValue) * orbitalOffset)
	look_at(get_parent().global_transform.origin, Vector3.UP)
	if delta:
		orbitalValue += deg_to_rad(8) * delta;

func cameraUpdate(yaw, pitch):
	pitch = clamp(pitch, -89 - total_pitch, 89 - total_pitch)
	total_pitch += pitch

	rotate_y(deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func setOrbital(newOrbital):
	orbital = newOrbital
	orbitalValue = 0
	if orbital:
		orbitalUpdate()
	else:
		position = Vector3(0, 0, 0)
		cameraUpdate(0, 0)
