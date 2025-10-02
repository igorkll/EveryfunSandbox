extends Camera3D

var total_pitch = 0.0
var sensitivity = 0.2
var orbital = false

func _input(event):
	if !orbital && event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var yaw = event.relative.x * sensitivity
		var pitch = event.relative.y * sensitivity
		cameraUpdate(yaw, pitch)
		
func cameraUpdate(yaw, pitch):
	pitch = clamp(pitch, -89 - total_pitch, 89 - total_pitch)
	total_pitch += pitch

	rotate_y(deg_to_rad(-yaw))
	rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func setOrbital(newOrbital):
	orbital = newOrbital
	if orbital:
		position = Vector3(0, 10, 0)
	else:
		position = Vector3(0, 0, 0)
		cameraUpdate(0, 0)
