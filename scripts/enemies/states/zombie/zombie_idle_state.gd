extends "res://scripts/enemies/states/enemystates/enemy_idle.gd"

var detection_range: float = 500.0

func _init():
	name = "zombie_idle"

func process_physics(_delta):
	if enemy.player:
		var distance = enemy.global_position.distance_to(enemy.player.global_position)
		
		if distance <= detection_range:
			state_machine.transition_to("chase")
