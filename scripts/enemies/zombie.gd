extends CharacterBody2D

@export var speed: int = 80
@export var health: int = 30
var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if randi() % 2 == 0:
		$Sprite2D.texture = preload("res://assets/models/enemies/zombie.png")
	else:
		$Sprite2D.texture = preload("res://assets/models/enemies/zombie2.png")

func _physics_process(_delta):
	if player == null:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Поворот в сторону игрока
	if direction.x != 0:
		$Sprite2D.flip_h = direction.x < 0
	
	move_and_slide()

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		queue_free()
