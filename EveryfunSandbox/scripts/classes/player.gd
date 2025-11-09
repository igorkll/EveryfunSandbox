extends human

var camera

func _ready():
	super._ready()
	camera = $camera
	camera.set_script(preload("res://scripts/classes/camera.gd"))
	camera.add_child(VoxelViewer.new())

func _physics_process(delta):
	
	
	super._physics_process(delta)
