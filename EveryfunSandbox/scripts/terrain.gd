extends VoxelLodTerrain

var world_generator = preload("res://generators/world.gd")

func _ready():
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = 2048
	self.lod_distance = 256
