extends basecharacter
class_name human

func _ready():
	character_radius = 0.25
	character_height = 1.8
	
	var camera = Camera3D.new()
	camera.name = "camera"
	camera.fov = 80
	camera.position = Vector3(0, 0.689, 0)
	add_child(camera)
	
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.25
	mesh.height = character_height
	
	initCharacter(null, mesh)

func _physics_process(delta):
	super._physics_process(delta)
