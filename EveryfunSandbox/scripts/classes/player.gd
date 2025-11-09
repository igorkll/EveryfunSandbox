extends human

var camera

var control_lock = false

func _ready():
	super._ready()
	camera = $camera
	camera.set_script(preload("res://scripts/classes/camera.gd"))
	camera.add_child(chunkloader.new())

func _physics_process(delta):
	
	
	super._physics_process(delta)
