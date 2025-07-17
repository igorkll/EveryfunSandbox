extends Node

static var texture = preload("res://blocks/pig/texture.png")

var rigid_body: RigidBody3D

func _ready():
	var obj = self
	if obj is RigidBody3D:
		rigid_body = obj as RigidBody3D

func _physics_process(delta):
	if rigid_body:
		rigid_body.apply_impulse(Vector3(0, 0.05, 0))
