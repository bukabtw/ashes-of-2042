extends CharacterBody2D

@export var speed: int = 200
@export var health: int = 100
@onready var sprite = $Sprite2D

func _physics_process(delta):
	# Движение (оставляем как было)
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
		if abs(input_dir.x) > abs(input_dir.y):
			sprite.flip_h = input_dir.x < 0
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _input(event):
	if event.is_action_pressed("attack"):
		attack()

func attack():
	print("Атакую!")
	var attack_range = $AttackRange
	for body in attack_range.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage(10)
