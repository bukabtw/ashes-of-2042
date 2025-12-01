extends CharacterBody2D

enum PlayerDirection { DOWN, UP, LEFT, RIGHT }
var current_direction: PlayerDirection = PlayerDirection.DOWN
var last_movement_direction: PlayerDirection = PlayerDirection.DOWN  # ⬅️ ДОБАВЬ ЭТУ СТРОКУ

@export var speed: int = 200
@export var health: int = 100
@export var attack_damage: int = 10

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_range = $AttackRange
@onready var state_machine = $PlayerStateMachine

const PlayerIdleState = preload("res://scripts/player/states/player_idle.gd")
const PlayerMoveState = preload("res://scripts/player/states/player_move.gd") 
const PlayerAttackState = preload("res://scripts/player/states/player_attack.gd")
const PlayerHurtState = preload("res://scripts/player/states/player_hurt.gd")

func _ready():
	var collision = $CollisionShape2D
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(24, 44)
	collision.position = Vector2(0, 10)
	
	setup_state_machine()

func setup_state_machine():
	# Создаем состояния
	var idle_state = PlayerIdleState.new()
	idle_state.setup_state(self, state_machine)
	
	var move_state = PlayerMoveState.new()
	move_state.setup_state(self, state_machine)
	
	var attack_state = PlayerAttackState.new()
	attack_state.setup_state(self, state_machine)
	
	var hurt_state = PlayerHurtState.new()
	hurt_state.setup_state(self, state_machine)
	
	# Инициализируем state machine
	state_machine.init_state("idle", idle_state)
	state_machine.init_state("move", move_state)
	state_machine.init_state("attack", attack_state)
	state_machine.init_state("hurt", hurt_state)
	
	state_machine.transition_to("idle")

func _input(event):
	state_machine.process_input(event)

func _process(delta):
	state_machine.process_frame(delta)

func _physics_process(delta):
	state_machine.process_physics(delta)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Игрок столкнулся с: ", collision.get_collider().name)

func take_damage(damage: int):
	# Добавляем проверку current_state
	if state_machine.current_state and state_machine.current_state.name != "hurt":
		health -= damage
		state_machine.transition_to("hurt")
		
		if health <= 0:
			die()

func die():
	print("Игрок умер!")
	get_tree().reload_current_scene()
