extends CharacterBody3D

var move_acceleration = 2
var fall_acceleration = 75
var jump_acceleration = 10

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
		velocity.y += jump_acceleration

	velocity.x += move_direction.x * move_acceleration
	velocity.z += move_direction.z * move_acceleration

	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)

	move_and_slide()
