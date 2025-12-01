extends Node
class_name EnemyStateMachine

var current_state: EnemyState
var states: Dictionary = {}

func init_state(state_name: String, state: EnemyState):
	print("STATE MACHINE: Добавляем состояние - ", state_name)
	states[state_name] = state

func transition_to(state_name: String):
	print("STATE MACHINE: Переход в - ", state_name)
	if state_name in states:
		if current_state:
			current_state.exit()
		current_state = states[state_name]
		current_state.enter()

func process_physics(delta: float):
	print("STATE MACHINE: process_physics ВЫЗВАН, текущее состояние: ", current_state.name if current_state else "null")
	if current_state:
		print("STATE MACHINE: Вызываю ", current_state.name, ".process_physics")
		current_state.process_physics(delta)
