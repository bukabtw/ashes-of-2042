extends EnemyState

func process_physics(_delta):
	if enemy.can_see_player():
		state_machine.transition_to("chase")

func get_animation_name(direction: String) -> String:
	return "idle_" + direction
