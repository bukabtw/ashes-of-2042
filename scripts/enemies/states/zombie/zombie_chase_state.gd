extends "res://scripts/enemies/states/enemystates/enemy_chase.gd"

var zombie_speed_multiplier: float = 0.7

func process_physics(_delta):
	if not enemy.player:
		print("CHASE: Игрок пропал!")
		state_machine.transition_to("idle")
		return
	
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	print("CHASE: Расстояние: ", distance)
	
	# ОБНОВЛЯЕМ НАПРАВЛЕНИЕ
	var direction = enemy.get_direction_towards_player()
	print("CHASE: Направление к игроку: ", direction)
	
	enemy.velocity = direction * (enemy.speed * zombie_speed_multiplier)
	enemy.update_direction(direction)  # ⬅️ ЭТО ВАЖНО!
	
	play_animation()
	
	if distance <= 60.0:
		print("CHASE: Атакую!")
		state_machine.transition_to("attack")
		return
	
	enemy.move_and_slide()
