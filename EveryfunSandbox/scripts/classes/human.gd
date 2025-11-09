extends basecharacter
class_name human

var cameraContainer

func _ready():
	character_radius = 0.25
	character_height = 1.8
	
	cameraContainer = Camera3D.new()
	cameraContainer.position = Vector3(0, 0.689, 0)
	add_child(cameraContainer)
	
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.25
	mesh.height = character_height
	
	initCharacter(null, mesh)

func _physics_process(delta):
	super._physics_process(delta)
