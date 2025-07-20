extends Camera3D

var total_pitch = 0.0
var sensitivity = 0.2

func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var yaw = event.relative.x * sensitivity
		var pitch = event.relative.y * sensitivity
		
		pitch = clamp(pitch, -89 - total_pitch, 89 - total_pitch)
		total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))
