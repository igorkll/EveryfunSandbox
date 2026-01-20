extends basecharacter
class_name human

var cameraContainer

func _ready():
	pass

func initHuman(hum:Humanizer, scale=1):
	character_radius = maxf((hum.get_max_width() / 2) * scale, consts.min_human_radius)
	character_height = hum.get_head_height() * scale
	
	var parentCharacter = hum.get_CharacterBody3D(false)
	parentCharacter.rotation_degrees = Vector3(0, 180, 0)
	
	for mesh in parentCharacter.get_children():
		if mesh is MeshInstance3D:
			mesh.scale = Vector3(scale, scale, scale)
	
	var eye_head_offset = -0.1
	
	cameraContainer = Node3D.new()
	cameraContainer.position = Vector3(0, (character_height / 2) + eye_head_offset, 0)
	add_child(cameraContainer)
	
	parentCharacter.position = Vector3(0, -(character_height / 2), 0)
	initCharacter(null, null, parentCharacter)

func _physics_process(delta):
	super._physics_process(delta)
