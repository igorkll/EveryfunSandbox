extends VoxelTerrain

var world_generator = preload("res://scripts/generators/empty.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = false
var deferredActions = []

var id: int

func init(bodyId: int):
	var idStr = str(id)
	id = bodyId
	
	var terrainPath = saves.getPathInSave("bodies".path_join(idStr + ".db"))
	filesystem.makeDirectoryForFile(terrainPath)
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.mesh_block_size = consts.chunk_size
	self.max_view_distance = game.view_distance
	self.stream = stream
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE

func _process(delta):
	self.max_view_distance = game.view_distance
	terrainUtils.applyDeferredActions(self)
