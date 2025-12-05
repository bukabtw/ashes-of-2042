extends Zombie

func _ready():
	super._ready()
	
	detection_range = 0.0
	

func setup_state_machine():
	var idle_state = ZombieIdleState.new()
	idle_state.setup_state(self, state_machine)
	
	var death_state = ZombieDeathState.new()
	death_state.setup_state(self, state_machine)
	
	state_machine.init_state("idle", idle_state)
	state_machine.init_state("death", death_state)
	
	state_machine.transition_to("idle")

func _on_detection_area_body_entered(_body):
	pass

func _on_attack_range_body_entered(_body):
	pass
