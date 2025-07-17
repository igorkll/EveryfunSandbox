extends CharacterBody3D

var sprint_mul = 2

var move_acceleration = 75
var fall_acceleration = 60
var jump_acceleration = 80

var max_fall_velocity = 200
var max_move_velocity = 6

var velocity_down = 0.0005
var jump_budget = 0.15


var current_jump = false
var current_jump_budget = 0

func _ready():
	position = (Vector3) (0, 2, 0)
		
func _physics_process(delta):
	var direction = Vector3.ZERO	

	var _max_move_velocity = max_move_velocity
	var _move_acceleration = move_acceleration
	if Input.is_action_pressed("move_sprint"):
		_max_move_velocity *= sprint_mul
		_move_acceleration *= sprint_mul

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
		
	if Input.is_action_pressed("move_jump") && is_on_floor():
		if not current_jump:
			current_jump_budget = jump_budget
		current_jump = true
		
	if current_jump:
		current_jump_budget -= delta
		if current_jump_budget < 0:
			current_jump = false
			current_jump_budget = 0
	
	if Input.is_action_just_released("move_jump"):
		current_jump = false
		current_jump_budget = 0
		
	var camera_basis = $Camera.global_transform.basis
	var camera_direction = -camera_basis.z.normalized()
	var camera_right = camera_basis.x.normalized()
	var move_direction = (camera_direction * direction.z + camera_right * direction.x).normalized()
	move_direction.y = 0
	move_direction = move_direction.normalized()

	velocity.x += move_direction.x * _move_acceleration * delta
	velocity.z += move_direction.z * _move_acceleration * delta

	if current_jump:
		velocity.y += jump_acceleration * delta
	elif not is_on_floor():
		velocity.y -= fall_acceleration * delta
		
	var velocity2d = Vector2 (velocity.x, velocity.z);
	if velocity2d.length() > _max_move_velocity:
		velocity2d = velocity2d.normalized() * _max_move_velocity
		velocity.x = velocity2d.x
		velocity.z = velocity2d.y
		
	if velocity.y < -max_fall_velocity:
		velocity.y = -max_fall_velocity
	
	var speed_mul = pow(velocity_down, delta);
	velocity.x *= speed_mul;
	velocity.z *= speed_mul;
	
	move_and_slide()
