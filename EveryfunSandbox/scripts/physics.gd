extends Node

func pulse(position, radius, power):
	var space = game.world.direct_space_state
	var shape = SphereShape3D.new()
	shape.radius = radius

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), position)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var results = space.intersect_shape(query)

	for hit in results:
		var body = hit["collider"]
		if body is RigidBody3D or body is CharacterBody3D:
			var dir = (body.global_position - position).normalized()
			var dist = body.global_position.distance_to(position)
			var strength = power * (1.0 - dist / radius)
			body.apply_impulse(dir * strength)
			

func explode(position, explosiveLevel):
	if explosiveLevel < 1:
		return
	
	var raycastDistance = explosiveLevel * 2
	var shrapnel = explosiveLevel * 4
	var level = explosiveLevel * 0.5
	var pulsePower = explosiveLevel * 5
	
	var explosionState = {
		"iterations": explosiveLevel * 1
	}
	
	pulse(position, raycastDistance, pulsePower)
	
	timers.setInterval(func():
		for i in range(shrapnel):
			var result = terrainUtils.blockRaycast(position, funcs.getRandomDirection(), raycastDistance)
			if result:
				if not terrainUtils.callBlock(result[0], result[1].position, "_explode"):
					terrainInteractions.destroyBlock(result[0], result[1].position, level * (1 - (result[1].distance / raycastDistance)))
		explosionState.iterations -= 1
		if explosionState.iterations < 1:
			return true
	, timers.tps_60)
