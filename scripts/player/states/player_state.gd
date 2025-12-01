# player_state.gd
extends Node
class_name PlayerState

var player: CharacterBody2D
var state_machine: PlayerStateMachine

func setup_state(player_ref: CharacterBody2D, state_machine_ref: PlayerStateMachine):
	player = player_ref
	state_machine = state_machine_ref

func get_animation_name(_direction: String) -> String:
	return ""

func enter():
	play_animation()

func exit():
	pass

func process_frame(_delta: float):
	pass

func process_input(_event: InputEvent):
	pass

func process_physics(_delta: float):
	pass

func play_animation():
	var anim_name = get_animation_name(get_direction_suffix())
	if anim_name != "" and player.animated_sprite.animation != anim_name:
		player.animated_sprite.play(anim_name)

func get_direction_suffix() -> String:
	if player:
		# Используем числовые значения (0, 1, 2, 3)
		match int(player.current_direction):
			0: return "back"    # DOWN = 0 = вниз = BACK
			1: return "front"   # UP = 1 = вверх = FRONT
			2: return "left"    # LEFT = 2
			3: return "right"   # RIGHT = 3
			_: return "back"
	return "back"
