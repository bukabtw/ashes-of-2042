extends "res://scripts/enemies/states/enemystates/enemy_death.gd"
class_name ZombieDeathState

func enter():
	enemy.velocity = Vector2.ZERO
	play_animation()
	
	spawn_death_effects()
	
	await enemy.animated_sprite.animation_finished
	enemy.queue_free()

func spawn_death_effects():
	print("Зомби умер! Должен быть эффект крови")
