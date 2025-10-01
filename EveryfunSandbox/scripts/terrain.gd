extends VoxelLodTerrain

var world_generator = preload("res://generators/world.gd")

func _ready():
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = "user://terrain.db"
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = 128
	self.lod_distance = 64
	self.stream = stream
