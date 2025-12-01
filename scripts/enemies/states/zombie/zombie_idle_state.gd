extends "res://scripts/enemies/states/enemystates/enemy_idle.gd"
class_name ZombieIdleState

var detection_range: float = 500.0

func _init():
	name = "zombie_idle"  # ⬅️ ДОБАВИТЬ ИМЯ

func process_physics(_delta):
	print("ZOMBIE IDLE: Проверяю игрока...")
	
	if enemy.player:
		var distance = enemy.global_position.distance_to(enemy.player.global_position)
		print("ZOMBIE IDLE: Расстояние: ", distance)
		
		# ПРИНУДИТЕЛЬНЫЙ ПЕРЕХОД ДЛЯ ТЕСТА
		if true:  # ⬅️ ВРЕМЕННО ВСЕГДА ПЕРЕХОДИМ В CHASE
			print("ZOMBIE IDLE: Принудительно перехожу в chase!")
			state_machine.transition_to("chase")
	else:
		print("ZOMBIE IDLE: Игрок = null")
