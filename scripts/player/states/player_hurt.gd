extends PlayerState

var hurt_timer: float = 0.0
var hurt_duration: float = 0.5

func enter():
	hurt_timer = 0.0

func process_physics(delta):
	hurt_timer += delta
	if hurt_timer >= hurt_duration:
		state_machine.transition_to("idle")
