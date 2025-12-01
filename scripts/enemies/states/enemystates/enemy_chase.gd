extends EnemyState

func process_physics(_delta):
	if not enemy.player:
		state_machine.transition_to("idle")
		return
	
	var direction = enemy.get_direction_towards_player()
	enemy.velocity = direction * enemy.speed
	enemy.update_direction(direction)
	
	play_animation()
	
	if enemy.global_position.distance_to(enemy.player.global_position) <= enemy.attack_range:
		state_machine.transition_to("attack")
	
	enemy.move_and_slide()

func get_animation_name(direction: String) -> String:
	return "move_" + direction
