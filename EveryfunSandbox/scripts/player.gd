extends CharacterBody3D

var sprint_mul = 2

var move_acceleration = 40
var fall_acceleration = 30
var jump_acceleration = 200

var velocity_down = 0.0005
var jump_budget = 0.05

var current_jump = false
var current_jump_budget = 0

var grabbed_block
var grab_pid

func raycast():
	var raycast = $RayCast
	raycast.global_transform.origin = $Camera.global_transform.origin
	raycast.target_position = -$Camera.global_transform.basis.z * 4
	raycast.force_raycast_update()
	return raycast
	
func grabMagned(body, delta):
	var camera_position = $Camera.global_transform.origin
	var camera_direction = -$Camera.global_transform.basis.z.normalized()
	var target_position = camera_position + (camera_direction * 5)
	body.apply_impulse(grab_pid.compute(target_position, body.position, delta))

func _ready():
	position = (Vector3) (0, 2, 0)
		
func _physics_process(delta):
	# ---------------------------------- moving control
		
	var direction = Vector3.ZERO	

	var _move_acceleration = move_acceleration
	if Input.is_action_pressed("sprint"):
		_move_acceleration *= sprint_mul

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
		
	if Input.is_action_pressed("jump") && is_on_floor():
		if not current_jump:
			current_jump_budget = jump_budget
		current_jump = true
		
	if current_jump:
		current_jump_budget -= delta
		if current_jump_budget < 0:
			current_jump = false
			current_jump_budget = 0
	
	if Input.is_action_just_released("jump"):
		current_jump = false
		current_jump_budget = 0
		
	# ---------------------------------- world control
		
	if Input.is_action_just_released("grab"):
		if grabbed_block:
			grabbed_block = null
		else:
			var raycast = raycast()
			if raycast.is_colliding():
				var collided_object = raycast.get_collider()
				if blockManager.isBlock(collided_object):
					grabbed_block = blockManager.toDynamic(collided_object)
					grab_pid = PID3.new()
					grab_pid.Kp = 4
					grab_pid.Ki = 0
					grab_pid.Kd = 1
				
	if Input.is_action_just_released("use"):
		var raycast = raycast()
		if raycast.is_colliding():
			var collided_object = raycast.get_collider()
			if blockManager.isBlock(collided_object):
				blockManager.interact(collided_object)
				
	# ---------------------------------- process
	
	if grabbed_block:
		grabMagned(grabbed_block, delta)
		
	# ---------------------------------- moving
	
	var camera_basis = $Camera.global_transform.basis
	var camera_direction = -camera_basis.z.normalized()
	var camera_right = camera_basis.x.normalized()
	var move_direction = (camera_direction * direction.z + camera_right * direction.x).normalized()
	move_direction.y = 0
	move_direction = move_direction.normalized()

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	velocity.y -= fall_acceleration * delta
	if current_jump:
		velocity.y += jump_acceleration * delta
	
	var speed_mul = pow(velocity_down, delta);
	velocity.x *= speed_mul;
	velocity.z *= speed_mul;
	
	move_and_slide()
