extends "res://scripts/enemies/states/enemystates/enemy_hurt.gd"

func _init():
	hurt_duration = 0.1

func enter():
	enemy.velocity = Vector2.ZERO
	hurt_timer = 0.0
	
	var knockback_direction = -enemy.get_direction_towards_player()
	enemy.velocity = knockback_direction * 100.0
	

func get_animation_name(direction: String) -> String:
	var hurt_anim = "hurt_" + direction
	
	if enemy.animated_sprite.sprite_frames.has_animation(hurt_anim):
		return hurt_anim
	else:
		return "idle_" + direction

func process_physics(delta):
	hurt_timer += delta
	enemy.velocity = enemy.velocity.move_toward(Vector2.ZERO, delta * 300.0)
	
	if hurt_timer >= hurt_duration:
		state_machine.transition_to("chase")
	
	enemy.move_and_slide()
