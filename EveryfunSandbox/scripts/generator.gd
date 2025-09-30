extends VoxelGeneratorScript

func _generate_block(buffer: VoxelBuffer, position: Vector3i, lod: int):
	var size = buffer.get_size()
	var scale = 1 << lod
	
	for ix in range(size.x):
		for iy in range(size.y):
			for iz in range(size.z):
				var localPos = Vector3i(ix, iy, iz)
				var worldPos = position + (localPos * scale)

				if worldPos.y == 11:
					buffer.set_voxel_v(1, localPos, VoxelBuffer.CHANNEL_TYPE)
				else:
					buffer.set_voxel_v(0, localPos, VoxelBuffer.CHANNEL_TYPE)
