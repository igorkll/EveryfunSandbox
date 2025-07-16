extends CharacterBody3D

var move_acceleration = 75
var fall_acceleration = 75
var jump_acceleration = 10

var max_fall_velocity = 250
var max_move_velocity = 15

var velocity_down = 0.1

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
		
	var camera_basis = $Camera.global_transform.basis
	var camera_direction = -camera_basis.z.normalized()
	var camera_right = camera_basis.x.normalized()
	var move_direction = (camera_direction * direction.z + camera_right * direction.x).normalized()

	if Input.is_action_pressed("move_jump"):
		velocity.y += jump_acceleration * delta

	velocity.x += move_direction.x * move_acceleration * delta
	velocity.z += move_direction.z * move_acceleration * delta

	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
		
	var velocity2d = Vector2 (velocity.x, velocity.z);
	if velocity2d.length() > max_move_velocity:
		velocity2d = velocity2d.normalized() * max_move_velocity
		velocity.x = velocity2d.x
		velocity.z = velocity2d.y
		
	if velocity.y < -max_fall_velocity:
		velocity.y = -max_fall_velocity
	
	var speed_mul = pow(velocity_down, delta);
	velocity.x *= speed_mul;
	velocity.z *= speed_mul;
	
	move_and_slide()
