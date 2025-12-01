extends PlayerState

func get_animation_name(direction: String) -> String:
	return "move_" + direction

func process_physics(_delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		player.velocity = input_dir * player.speed

		if abs(input_dir.x) > abs(input_dir.y):
			player.current_direction = 3 if input_dir.x > 0 else 2  # RIGHT/LEFT
		else:
			player.current_direction = 0 if input_dir.y > 0 else 1  # DOWN/UP
		
		play_animation()
	else:
		# ⬇️ ВАЖНО: Сохраняем текущее направление при переходе в idle
		player.last_movement_direction = player.current_direction
		state_machine.transition_to("idle")
	
	player.move_and_slide()
