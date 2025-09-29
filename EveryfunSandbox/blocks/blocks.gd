extends Node

var material

func _ready():
	material = ShaderMaterial.new()
	material.shader = load("res://blocks/blocks.gdshader")
