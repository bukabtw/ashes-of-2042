extends EnemyBase

# ⬇️ ИСПРАВЛЯЕМ ПУТИ - добавляем _state
const ZombieIdleState = preload("res://scripts/enemies/states/zombie/zombie_idle_state.gd")
const ZombieChaseState = preload("res://scripts/enemies/states/zombie/zombie_chase_state.gd")
const ZombieAttackState = preload("res://scripts/enemies/states/zombie/zombie_attack_state.gd")
const ZombieHurtState = preload("res://scripts/enemies/states/zombie/zombie_hurt_state.gd")
const ZombieDeathState = preload("res://scripts/enemies/states/zombie/zombie_death_state.gd")

func setup_state_machine():
	var idle_state = ZombieIdleState.new()
	idle_state.setup_state(self, state_machine)
	
	var chase_state = ZombieChaseState.new()
	chase_state.setup_state(self, state_machine)
	
	var attack_state = ZombieAttackState.new()
	attack_state.setup_state(self, state_machine)
	
	var hurt_state = ZombieHurtState.new()
	hurt_state.setup_state(self, state_machine)
	
	var death_state = ZombieDeathState.new()
	death_state.setup_state(self, state_machine)
	
	state_machine.init_state("idle", idle_state)
	state_machine.init_state("chase", chase_state)
	state_machine.init_state("attack", attack_state)
	state_machine.init_state("hurt", hurt_state)
	state_machine.init_state("death", death_state)
	
	state_machine.transition_to("idle")
	
func _physics_process(delta):
	# ВЫЗЫВАЕМ State Machine чтобы состояния работали
	state_machine.process_physics(delta)
	
	# Проверка столкновений (опционально)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Зомби столкнулся с: ", collision.get_collider().name)
	# Проверка столкновений
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Зомби столкнулся с: ", collision.get_collider().name)

func _ready():
	# Принудительно включаем обработку
	set_physics_process(true)
	set_process(true)
	
	player = get_tree().get_first_node_in_group("player")
	print("ЗОМБИ: Игрок найден - ", player != null)
	print("ЗОМБИ: Physics process включен - ", is_physics_processing())
	
	setup_state_machine()
	
	# Проверяем что состояния создались
	print("ЗОМБИ: Состояния инициализированы")
