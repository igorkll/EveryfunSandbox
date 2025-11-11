extends Node

var direct_space_state

func updateDirectSpaceState():
	var newState = game.world.direct_space_state
	if newState != null:
		direct_space_state = newState

func pulseObject(position, radius, power, object):
	var dir = (object.global_position - position).normalized()
	var dist = object.global_position.distance_to(position)
	var strength = power * (1.0 - dist / radius)
	object.apply_impulse(dir * strength)
	
func pulseObjectToDirection(position, radius, power, dir, object):
	var dist = object.global_position.distance_to(position)
	var strength = power * (1.0 - dist / radius)
	object.apply_impulse(dir * strength)

func pulse(position, radius, power):
	var shape = SphereShape3D.new()
	shape.radius = radius

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), position)
	query.collide_with_areas = false
	query.collide_with_bodies = true

	if not direct_space_state:
		return
	
	var results = direct_space_state.intersect_shape(query)
	for hit in results:
		var body = hit["collider"]
		if body is RigidBody3D or body is CharacterBody3D:
			pulseObject(position, radius, power, body)
			

func explode(position, explosiveLevel):
	if explosiveLevel < 1:
		return
		
	updateDirectSpaceState()
	
	var raycastDistance = explosiveLevel * 2
	var shrapnel = explosiveLevel * 15
	var level = explosiveLevel * 0.5
	var pulsePower = explosiveLevel * 20
	var minimalDistance = explosiveLevel * 0.5
	
	var explosionState = {
		"iterations": explosiveLevel * 1
	}
	
	pulse(position, raycastDistance, pulsePower)
	
	timers.setInterval(func():
		for i in range(shrapnel):
			var result = terrainUtils.blockRaycast(position, funcs.getRandomDirection(), raycastDistance)
			if result:
				if not terrainUtils.callBlock(result[0], result[1].position, "_explode"):
					var fraction = max(0, result[1].distance - minimalDistance) / (raycastDistance - minimalDistance)
					if not terrainInteractions.destroyBlock(result[0], result[1].position, level * (1 - fraction)):
						if randf() < fraction:
							var body = terrainUtils.makeDynamic(result[0], result[1].position)
							pulseObject(position, raycastDistance, pulsePower / 2, body)
							pulseObjectToDirection(position, raycastDistance, pulsePower / 2, Vector3.UP, body)
		explosionState.iterations -= 1
		if explosionState.iterations < 1:
			return true
	, timers.tps_60)
