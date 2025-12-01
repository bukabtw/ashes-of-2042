extends PlayerState

func enter():
	player.velocity = Vector2.ZERO
	player.collision_layer = 0
	
	play_animation()
	
	await player.animated_sprite.animation_finished
	
	var scene_tree = player.get_tree()
	if scene_tree:
		await scene_tree.create_timer(3.0).timeout
	
	var _result = get_tree().reload_current_scene()

func get_animation_name(_direction: String) -> String:
	return "death"
