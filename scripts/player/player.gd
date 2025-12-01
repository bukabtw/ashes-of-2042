extends CharacterBody2D

enum PlayerDirection { DOWN, UP, LEFT, RIGHT }
var current_direction: PlayerDirection = PlayerDirection.DOWN
var last_movement_direction: PlayerDirection = PlayerDirection.DOWN

@export var speed: int = 200
@export var attack_damage: int = 10

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var state_machine = $PlayerStateMachine
@onready var health_component = $HealthComponent

const PlayerIdleState = preload("res://scripts/player/states/player_idle.gd")
const PlayerMoveState = preload("res://scripts/player/states/player_move.gd") 
const PlayerAttackState = preload("res://scripts/player/states/player_attack.gd")
const PlayerHurtState = preload("res://scripts/player/states/player_hurt.gd")
const PlayerDeathState = preload("res://scripts/player/states/player_death.gd")

func _ready():
	var collision = $CollisionShape2D
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(24, 44)
	collision.position = Vector2(0, 10)
	
	var attack_range_node = $AttackRange
	if attack_range_node:
		attack_range_node.collision_layer = 1 << 3
		attack_range_node.collision_mask = 1 << 1
	
	setup_state_machine()
	health_component.health_depleted.connect(_on_health_depleted)

func setup_state_machine():
	var idle_state = PlayerIdleState.new()
	idle_state.setup_state(self, state_machine)
	
	var move_state = PlayerMoveState.new()
	move_state.setup_state(self, state_machine)
	
	var attack_state = PlayerAttackState.new()
	attack_state.setup_state(self, state_machine)
	
	var hurt_state = PlayerHurtState.new()
	hurt_state.setup_state(self, state_machine)
	
	var death_state = PlayerDeathState.new()
	death_state.setup_state(self, state_machine)
	
	state_machine.init_state("idle", idle_state)
	state_machine.init_state("move", move_state)
	state_machine.init_state("attack", attack_state)
	state_machine.init_state("hurt", hurt_state)
	state_machine.init_state("death", death_state)
	
	state_machine.transition_to("idle")

func _input(event):
	state_machine.process_input(event)

func _process(delta):
	state_machine.process_frame(delta)

func _physics_process(delta):
	state_machine.process_physics(delta)

func take_damage(damage: int):
	if health_component:
		health_component.take_damage(damage)
		if state_machine.current_state and \
		   state_machine.current_state.name != "hurt" and \
		   state_machine.current_state.name != "death" and \
		   health_component.current_health > 0:
			state_machine.transition_to("hurt")

func _on_health_depleted():
	print("Игрок умер!")
	state_machine.transition_to("death")

func die():
	print("Перезагрузка сцены...")
	get_tree().reload_current_scene()
