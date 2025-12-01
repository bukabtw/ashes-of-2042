extends "res://scripts/enemies/states/enemystates/enemy_chase.gd"

var zombie_speed_multiplier: float = 0.7

func process_physics(_delta):
	if not enemy.player:
		state_machine.transition_to("idle")
		return
	
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	var direction = enemy.get_direction_towards_player()
	enemy.velocity = direction * (enemy.speed * zombie_speed_multiplier)
	enemy.update_direction(direction)
	
	play_animation()
	
	if distance <= 60.0:
		state_machine.transition_to("attack")
		return
	
	enemy.move_and_slide()
