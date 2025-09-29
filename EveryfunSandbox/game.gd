extends Node

var blockMaterial

func _ready():
	blockMaterial = StandardMaterial3D.new()
	blockMaterial.albedo_color = Color(0.621, 0.305, 0.016, 1.0)
