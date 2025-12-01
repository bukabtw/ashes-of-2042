extends "res://scripts/enemies/states/enemystates/enemy_hurt.gd"
class_name ZombieHurtState

func _init():
	# Зомби быстро восстанавливаются после урона
	hurt_duration = 0.2  # Быстрее чем обычные враги

func enter():
	enemy.velocity = Vector2.ZERO
	hurt_timer = 0.0
	
	# Зомби могут иногда отбрасываться при получении урона
	var knockback_direction = -enemy.get_direction_towards_player()
	enemy.velocity = knockback_direction * 100.0
	
	play_animation()

func process_physics(delta):
	hurt_timer += delta
	# Постепенно замедляем отбрасывание
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, delta * 300.0)
	
	if hurt_timer >= hurt_duration:
		state_machine.transition_to("chase")
	
	enemy.move_and_slide()
