extends Node
class_name PlayerStateMachine

var current_state: PlayerState
var states: Dictionary = {}

func init_state(state_name: String, state: PlayerState):
	states[state_name] = state

func transition_to(state_name: String):
	if state_name in states:
		if current_state:
			current_state.exit()
		current_state = states[state_name]
		current_state.enter()

func process_input(event: InputEvent):
	if current_state:
		current_state.process_input(event)

func process_frame(delta: float):
	if current_state:
		current_state.process_frame(delta)

func process_physics(delta: float):
	if current_state:
		current_state.process_physics(delta)
