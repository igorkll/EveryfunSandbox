extends Node3D
class_name chunkloader

var voxel_viewer

func _ready():
	game.chunkloaders.append(self)
	connect("tree_exiting", _on_tree_exiting)
	
	voxel_viewer = VoxelViewer.new()
	add_child(voxel_viewer)
	
func _physics_process(delta):
	if game.minimal_loading_area:
		voxel_viewer.view_distance = consts.start_loading_area
		voxel_viewer.view_distance_vertical_ratio = 1
	else:
		voxel_viewer.view_distance = game.view_distance
		voxel_viewer.view_distance_vertical_ratio = game.view_distance_vertical_ratio

func _on_tree_exiting():
	game.chunkloaders.erase(self)
