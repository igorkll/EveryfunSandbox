extends VoxelLodTerrain

var world_generator = preload("res://generators/world.gd")
var voxel_tool
var loadedTime = 0

func init(terrainPath):
	threaded_update_enabled = true
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = 32
	self.lod_distance = 32
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _process(delta):
	loadedTime += delta
	if loadedTime > 5 and (game.view_distance != view_distance or game.lod_distance != lod_distance):
		view_distance = game.view_distance
		lod_distance = game.lod_distance
