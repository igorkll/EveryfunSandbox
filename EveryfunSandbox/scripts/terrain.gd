extends VoxelLodTerrain

var world_generator = preload("res://generators/world.gd")
var voxel_tool

func init(terrainPath):
	threaded_update_enabled = true
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = game.view_distance
	self.lod_distance = game.lod_distance
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
