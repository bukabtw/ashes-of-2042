extends "res://scripts/enemies/states/enemystates/enemy_attack.gd"

var zombie_attack_multiplier: float = 1.5

func _init():
	attack_cooldown = 1.5

func enter():
	enemy.velocity = Vector2.ZERO
	attack_timer = 0.0
	play_animation()
	perform_attack()

func perform_attack():
	if enemy.player:
		var distance = enemy.global_position.distance_to(enemy.player.global_position)
		if distance <= enemy.attack_range:
			var actual_damage = enemy.attack_damage * zombie_attack_multiplier
			enemy.player.take_damage(actual_damage)
		else:
			# Игрок убежал - возвращаемся в погоню
			state_machine.transition_to("chase")

func process_physics(delta):
	attack_timer += delta
	if attack_timer >= attack_cooldown:
		state_machine.transition_to("chase")
