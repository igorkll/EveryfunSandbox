extends basecharacter
class_name human

var cameraContainer

func createCharacter():
	var config = HumanConfig.new()
	config.targets['gender'] = 0.0
	config.init_macros()
	config.eye_color = Color.GREEN
	config.hair_color = Color.PURPLE
	config.eyebrow_color = Color("550055")
	config.rig = "game_engine-RETARGETED"
	config.add_equipment(HumanizerEquipment.new("DefaultBody"))
	config.add_equipment(HumanizerEquipment.new("Pants-SkinnyJeans"))
	config.add_equipment(HumanizerEquipment.new("Shirt-MakeHumanTShirt"))
	config.add_equipment(HumanizerEquipment.new("Shoes-02"))
	config.add_equipment(HumanizerEquipment.new("RightEye-LowPolyEyeball"))
	config.add_equipment(HumanizerEquipment.new("LeftEye-LowPolyEyeball"))
	config.add_equipment(HumanizerEquipment.new("RightEyebrow-002"))
	config.add_equipment(HumanizerEquipment.new("LeftEyebrow-002"))
	config.add_equipment(HumanizerEquipment.new("RightEyelash"))
	config.add_equipment(HumanizerEquipment.new("LeftEyelash"))
	
	var hum := Humanizer.new()
	hum.load_config_async(config)
	return hum.get_CharacterBody3D(false)

func _ready():
	character_radius = 0.45
	character_height = 1.8
	
	cameraContainer = Node3D.new()
	cameraContainer.position = Vector3(0, 0.689, 0)
	add_child(cameraContainer)
	
	var mesh = CapsuleMesh.new()
	mesh.radius = character_radius
	mesh.height = character_height
	
	add_child(createCharacter())
	
	initCharacter(null, mesh)

func _physics_process(delta):
	super._physics_process(delta)
