extends CharacterBody3D

# Настройки движения
var speed = 5.0
var jump_speed = 10.0
var gravity = -9.8
var velocity = Vector3()

# Флаг для проверки, на земле ли игрок
var is_on_ground = false

func _physics_process(delta):
	# Проверка, на земле ли игрок
	is_on_ground = is_on_floor()

	# Обработка ввода для движения
	var direction = Vector3()

	if Input.is_action_pressed("ui_up"):  # Вперед
		direction += -transform.basis.z
	if Input.is_action_pressed("ui_down"):  # Назад
		direction += transform.basis.z
	if Input.is_action_pressed("ui_left"):  # Влево
		direction += -transform.basis.x
	if Input.is_action_pressed("ui_right"):  # Вправо
		direction += transform.basis.x

	direction = direction.normalized()  # Нормализуем вектор направления

	# Применение скорости движения
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Применение гравитации
	if is_on_ground:
		velocity.y = 0  # Сбрасываем вертикальную скорость при касании земли
		if Input.is_action_just_pressed("ui_accept"):  # Прыжок
			velocity.y = jump_speed

	# Применение гравитации
	velocity.y += gravity * delta

	# Движение игрока
	velocity = move_and_slide(velocity, Vector3.UP)
