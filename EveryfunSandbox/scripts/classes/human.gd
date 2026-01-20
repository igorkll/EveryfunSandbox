extends basecharacter
class_name human

var cameraContainer

func _ready():
	var hum := characterUtils.createHuman()
	character_radius = hum.get_max_width() / 2
	character_height = hum.get_head_height()
	
	var eye_head_offset = -0.1
	
	cameraContainer = Node3D.new()
	cameraContainer.position = Vector3(0, (character_height / 2) + eye_head_offset, 0)
	add_child(cameraContainer)
	
	var parentCharacter = hum.get_CharacterBody3D(false)
	initCharacter(null, null, parentCharacter)

func _physics_process(delta):
	super._physics_process(delta)
