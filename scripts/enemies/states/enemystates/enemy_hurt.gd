extends EnemyState

var hurt_timer: float = 0.0
var hurt_duration: float = 0.3

func enter():
	enemy.velocity = Vector2.ZERO
	hurt_timer = 0.0
	play_animation()

func process_physics(delta):
	hurt_timer += delta
	if hurt_timer >= hurt_duration:
		state_machine.transition_to("chase")

func get_animation_name(direction: String) -> String:
	return "hurt_" + direction
