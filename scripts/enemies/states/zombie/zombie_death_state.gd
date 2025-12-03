extends "res://scripts/enemies/states/enemystates/enemy_death.gd"

func enter():
	enemy.velocity = Vector2.ZERO
	
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	
	play_animation()
	
	
	if enemy.animated_sprite.sprite_frames.has_animation("death"):
		await enemy.animated_sprite.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	enemy.queue_free()

func get_animation_name(direction: String) -> String:
	if enemy.animated_sprite.sprite_frames.has_animation("death"):
		return "death"
	else:
		return "hurt_" + direction
