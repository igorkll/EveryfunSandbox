extends Node

static var texture = preload("res://textures/sky.hdr")

var rigid_body

func _ready():
	var parent = get_parent()
	if parent is RigidBody3D:
		rigid_body = parent

func _physics_process(delta):
	if rigid_body:
		rigid_body.apply_impulse(Vector3(0, 20, 0))
