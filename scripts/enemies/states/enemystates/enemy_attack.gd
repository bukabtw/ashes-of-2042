extends EnemyState

var attack_timer: float = 0.0
var attack_cooldown: float = 1.0

func enter():
	enemy.velocity = Vector2.ZERO
	attack_timer = 0.0
	perform_attack()

func perform_attack():
	if enemy.player and enemy.global_position.distance_to(enemy.player.global_position) <= enemy.attack_range:
		enemy.player.take_damage(enemy.attack_damage)

func process_physics(delta):
	attack_timer += delta
	if attack_timer >= attack_cooldown:
		state_machine.transition_to("chase")

func get_animation_name(direction: String) -> String:
	return "attack_" + direction
