extends VoxelTerrain

var world_generator = preload("res://generators/empty.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = false
var id: int

func init(bodyId: int):
	var idStr = str(id)
	id = bodyId
	name = "body_" + idStr
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = saves.getPathInSave("bodies".path_join(idStr + ".db"))
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.view_distance = game.view_distance
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
