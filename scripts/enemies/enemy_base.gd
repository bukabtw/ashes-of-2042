extends CharacterBody2D
class_name EnemyBase

enum EnemyDirection { DOWN, UP, LEFT, RIGHT }
var current_direction: EnemyDirection = EnemyDirection.DOWN

@export var enemy_type: String = "zombie"
@export_group("Stats")
@export var speed: float = 80.0
@export var health: int = 30
@export var attack_damage: int = 10
@export var attack_range: float = 60.0  # ⬅️ Изменил с 5.0 на 60.0
@export var detection_range: float = 500.0

var player: Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine = $EnemyStateMachine

func _ready():
	player = get_tree().get_first_node_in_group("player")
	setup_state_machine()

# Переопределяется в конкретных врагах
func setup_state_machine():
	pass

func _process(delta):
	pass  # ⬅️ Оставляем пустым

func _physics_process(delta):
	print("ENEMY BASE: physics_process ВЫЗВАН")  # ⬅️ ДОБАВИТЬ
	state_machine.process_physics(delta)

func take_damage(damage: int):
	health -= damage
	
	# Переходим в состояние получения урона
	if state_machine.current_state.name != "hurt" and state_machine.current_state.name != "death":
		state_machine.transition_to("hurt")
	
	if health <= 0:
		state_machine.transition_to("death")

func get_zombie_speed() -> float:
	return speed * 0.7 

func die():
	queue_free()

# Общие методы для всех врагов
func can_see_player() -> bool:
	return player and global_position.distance_to(player.global_position) <= detection_range

func get_direction_towards_player() -> Vector2:
	if not player:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func update_direction(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		current_direction = 3 if direction.x > 0 else 2  # RIGHT/LEFT
	else:
		current_direction = 0 if direction.y > 0 else 1  # DOWN/UP
