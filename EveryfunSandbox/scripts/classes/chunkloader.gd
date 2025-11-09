extends Node3D
class_name chunkloader

var voxel_viewer

func _ready():
	game.chunkloaders.append(self)
	connect("tree_exiting", _on_tree_exiting)
	
	add_child(VoxelViewer.new())
	
func _physics_process(delta):
	voxel_viewer.view_distance = game.view_distance

func _on_tree_exiting():
	game.chunkloaders.erase(self)
