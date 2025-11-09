extends basecharacter
class_name human

func _ready():
	var camera = Camera3D.new()
	camera.fov = 80
	camera.position = Vector3(0, 0.689, 0)
	add_child(camera)
	
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.25
	mesh.height = 1.8
	
	var collision = game.collisionFromMesh(mesh)
	
	initCharacter(collision, mesh)

func _physics_process(delta):
	super._physics_process(delta)
