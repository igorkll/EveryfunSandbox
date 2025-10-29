extends VoxelTerrain

var world_generator = preload("res://generators/empty.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = false

func init(terrainPath):
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = game.view_distance
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
