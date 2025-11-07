extends VoxelTerrain

var world_generator = preload("res://scripts/generators/empty.gd")
var blockChildren = {}
var voxel_tool
var isMainTerrain = false
var deferredActions = []

var _colliders = {}
var id: int

func _ready():
	self.connect("mesh_block_entered", _block_loaded)
	self.connect("block_unloaded", _block_unloaded)

func init(bodyId: int):
	id = bodyId
	var terrainPath = bodyUtils.getBodyTerrainPath(bodyId)
	
	var mesher = VoxelMesherBlocky.new()
	mesher.library = game.blockLibrary
	
	var stream = VoxelStreamSQLite.new()
	stream.database_path = terrainPath
	
	self.mesher = mesher
	self.generator = world_generator.new()
	self.mesh_block_size = consts.chunk_size
	self.max_view_distance = game.view_distance
	self.stream = stream
	self.generate_collisions = false
	
	voxel_tool = get_voxel_tool()
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE
	
func _block_loaded(pos):
	var colliderShape = blockUtils.getBlockCollider(terrainUtils.getBlockId(self, pos))
	if colliderShape:
		var collider = CollisionShape3D.new()
		collider.position = pos
		collider.shape = colliderShape
		get_parent().add_child(collider)
		_colliders[pos] = collider
		
func _block_unloaded(pos):
	var collider = _colliders.get(pos)
	if collider:
		collider.queue_free()
		_colliders.erase(pos)

func _process(delta):
	self.max_view_distance = game.view_distance
	terrainUtils.applyDeferredActions(self)
