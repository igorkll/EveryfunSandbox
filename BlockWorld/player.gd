extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		$Camera.rotate(Vector3.UP, -event.relative.x * 0.002)
		$Camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * 0.002)
		$Camera.rotation_degrees.z = clamp($Camera.rotation_degrees.z, -90, 90)
