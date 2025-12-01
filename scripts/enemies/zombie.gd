extends EnemyBase

const ZombieIdleState = preload("res://scripts/enemies/states/zombie/zombie_idle_state.gd")
const ZombieChaseState = preload("res://scripts/enemies/states/zombie/zombie_chase_state.gd")
const ZombieAttackState = preload("res://scripts/enemies/states/zombie/zombie_attack_state.gd")
const ZombieHurtState = preload("res://scripts/enemies/states/zombie/zombie_hurt_state.gd")
const ZombieDeathState = preload("res://scripts/enemies/states/zombie/zombie_death_state.gd")

@onready var health_component = $HealthComponent

func _ready():
	add_to_group("enemies")
	
	super._ready()
	
	if health_component:
		health_component.max_health = health
		health_component.current_health = health
		health_component.health_depleted.connect(_on_health_depleted)
	else:
		print("Внимание: HealthComponent не найден на зомби!")
	
	setup_state_machine()

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

func take_damage(damage: int):
	if health_component:
		health_component.take_damage(damage)
		
		var current_state = state_machine.current_state.name if state_machine.current_state else ""
		
		if current_state != "death" and current_state != "attack":
			state_machine.transition_to("hurt")
	else:
		health -= damage
		
		if state_machine.current_state and state_machine.current_state.name != "hurt":
			state_machine.transition_to("hurt")
		
		if health <= 0:
			state_machine.transition_to("death")

func _on_health_depleted():
	state_machine.transition_to("death")
