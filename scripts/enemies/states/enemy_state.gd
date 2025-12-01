# enemy_state.gd
extends Node
class_name EnemyState

var enemy: EnemyBase
var state_machine: EnemyStateMachine

func setup_state(enemy_ref: EnemyBase, state_machine_ref: EnemyStateMachine):
	enemy = enemy_ref
	state_machine = state_machine_ref

func get_animation_name(_direction: String) -> String:
	return ""

func enter():
	play_animation()

func exit():
	pass

func process_frame(_delta: float):
	pass

func process_physics(_delta: float):
	pass

func play_animation():
	var anim_name = get_animation_name(get_direction_suffix())
	
	if anim_name != "":
		if enemy.animated_sprite.sprite_frames.has_animation(anim_name):
			if enemy.animated_sprite.animation != anim_name:
				enemy.animated_sprite.play(anim_name)
		else:
			print("Анимация '", anim_name, "' не найдена. Использую fallback.")
			play_fallback_animation()

func play_fallback_animation():
	var direction = get_direction_suffix()
	
	var possible_animations = [
		"idle_" + direction,
		"move_" + direction,
		"idle_back",
		"move_back"
	]
	
	for anim in possible_animations:
		if enemy.animated_sprite.sprite_frames.has_animation(anim):
			enemy.animated_sprite.play(anim)
			return
	
	print("Не найдено подходящих анимаций для fallback")

func get_direction_suffix() -> String:
	# Получаем направление из врага
	if enemy:
		# Используем числовые значения (0, 1, 2, 3) вместо enum
		match enemy.current_direction:
			0: return "back"    # DOWN = 0 = вниз = BACK
			1: return "front"   # UP = 1 = вверх = FRONT
			2: return "left"    # LEFT = 2
			3: return "right"   # RIGHT = 3
			_: return "back"
	return "back"
