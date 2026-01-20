extends Node3D
class_name MusicSuppressor

var enabled = false
var radius = 32

func _ready():
	game.musicSuppressors.append(self)
	connect("tree_exiting", _on_tree_exiting)

func _on_tree_exiting():
	game.musicSuppressors.erase(self)
