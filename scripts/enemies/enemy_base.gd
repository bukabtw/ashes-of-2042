extends CharacterBody2D
class_name EnemyBase

enum EnemyDirection { DOWN, UP, LEFT, RIGHT }
var current_direction: EnemyDirection = EnemyDirection.DOWN

@export var enemy_type: String = "zombie"
@export_group("Stats")
@export var speed: float = 80.0
@export var health: int = 30
@export var attack_damage: int = 10
@export var attack_range: float = 60.0
@export var detection_range: float = 500.0

var player: Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine = $EnemyStateMachine

func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	self.collision_layer = 1 << 1
	self.collision_mask = (1 << 0) | (1 << 2)
	
	setup_state_machine()

func setup_state_machine():
	pass

func _physics_process(delta):
	state_machine.process_physics(delta)

func take_damage(damage: int):
	health -= damage
	
	if state_machine.current_state and \
	   state_machine.current_state.name != "hurt" and \
	   state_machine.current_state.name != "death":
		state_machine.transition_to("hurt")
	
	if health <= 0:
		state_machine.transition_to("death")

func die():
	queue_free()

func can_see_player() -> bool:
	return player and global_position.distance_to(player.global_position) <= detection_range

func get_direction_towards_player() -> Vector2:
	if not player:
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

func update_direction(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		current_direction = EnemyDirection.RIGHT if direction.x > 0 else EnemyDirection.LEFT
	else:
		current_direction = EnemyDirection.DOWN if direction.y > 0 else EnemyDirection.UP
