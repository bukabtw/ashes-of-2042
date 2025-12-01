extends EnemyState

func enter():
	enemy.velocity = Vector2.ZERO
	play_animation()
	await enemy.animated_sprite.animation_finished
	enemy.queue_free()

func get_animation_name(direction: String) -> String:
	return "death_" + direction
