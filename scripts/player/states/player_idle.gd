extends PlayerState

func get_animation_name(direction: String) -> String:
	return "idle_" + direction

func process_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
	
	if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
		state_machine.transition_to("move")
