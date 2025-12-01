extends EnemyState

var patrol_points: Array[Vector2] = []
var current_patrol_index: int = 0
var patrol_speed: float = 50.0

func enter():
	if patrol_points.is_empty():
		patrol_points = [
			enemy.global_position + Vector2(100, 0),
			enemy.global_position + Vector2(0, 100),
			enemy.global_position + Vector2(-100, 0),
			enemy.global_position + Vector2(0, -100)
		]

func process_physics(_delta):
	if enemy.can_see_player():
		state_machine.transition_to("chase")
		return
	
	var target_point = patrol_points[current_patrol_index]
	var direction = (target_point - enemy.global_position).normalized()
	enemy.velocity = direction * patrol_speed
	enemy.update_direction(direction)
	
	play_animation()
	
	if enemy.global_position.distance_to(target_point) < 10.0:
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	
	enemy.move_and_slide()

func get_animation_name(direction: String) -> String:
	return "move_" + direction
