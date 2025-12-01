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
	print("STATE: ", name, " выполняется")  # ⬅️ ДОБАВИТЬ ЭТУ СТРОКУ
	pass

func play_animation():
	var anim_name = get_animation_name(get_direction_suffix())
	if anim_name != "" and enemy.animated_sprite.animation != anim_name:
		enemy.animated_sprite.play(anim_name)

func get_direction_suffix() -> String:
	match enemy.current_direction:
		0: return "front"   # DOWN
		1: return "back"    # UP
		2: return "left"    # LEFT  
		3: return "right"   # RIGHT
		_: return "front"
