extends Node3D
class_name chunkloader

var voxel_viewer

func _ready():
	game.chunkloaders.append(self)
	connect("tree_exiting", _on_tree_exiting)
	
	voxel_viewer = VoxelViewer.new()
	add_child(voxel_viewer)
	
func _physics_process(delta):
	voxel_viewer.view_distance = game.view_distance
	voxel_viewer.view_distance_vertical_ratio = game.view_distance_vertical_ratio

func _on_tree_exiting():
	game.chunkloaders.erase(self)
