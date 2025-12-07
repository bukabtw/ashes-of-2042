extends Area2D
class_name NPCAdvanced

@export var npc_name: String = "npc"
@export var default_dialogue: String = "start"
@export var repeat_dialogue: String = "repeat"
@export var quest_complete_dialogue: String = "after_quest"

enum DialogueState { FIRST_TIME, REPEAT, QUEST_COMPLETE }
var dialogue_state: DialogueState = DialogueState.FIRST_TIME
var dialogue_history: Array = []  # Какие диалоги уже были

var player_in_range: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Загружаем историю диалогов из сохранения (если есть)
	load_dialogue_history()

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		start_dialogue()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		show_interaction_hint()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		hide_interaction_hint()

func start_dialogue():
	if not DialogueManager:
		print("DialogueManager не найден")
		return
	
	# Определяем, какой диалог показывать
	var dialogue_to_show = get_dialogue_to_show()
	
	# Загружаем ресурс диалога
	var dialogue_path = "res://dialogue/%s.dialogue" % npc_name
	var resource = load(dialogue_path)
	
	if resource:
		DialogueManager.show_dialogue_balloon(resource, dialogue_to_show)
		# Сохраняем, что этот диалог был показан
		mark_dialogue_shown(dialogue_to_show)
		
		# После первого диалога переключаем состояние
		if dialogue_state == DialogueState.FIRST_TIME:
			dialogue_state = DialogueState.REPEAT
			save_dialogue_history()
	else:
		print("Не могу загрузить диалог: ", dialogue_path)

func get_dialogue_to_show() -> String:
	match dialogue_state:
		DialogueState.FIRST_TIME:
			return default_dialogue
		DialogueState.REPEAT:
			return repeat_dialogue
		DialogueState.QUEST_COMPLETE:
			return quest_complete_dialogue
		_:
			return default_dialogue

func mark_dialogue_shown(dialogue_id: String):
	if not dialogue_history.has(dialogue_id):
		dialogue_history.append(dialogue_id)

func set_dialogue_state(new_state: DialogueState):
	dialogue_state = new_state
	save_dialogue_history()

func complete_quest():
	dialogue_state = DialogueState.QUEST_COMPLETE
	save_dialogue_history()

func show_interaction_hint():
	# Можно добавить иконку или текст над NPC
	print("Нажми E - поговорить с ", npc_name)

func hide_interaction_hint():
	pass

func save_dialogue_history():
	# Сохраняем в глобальные переменные или файл
	var save_data = {
		"state": dialogue_state,
		"history": dialogue_history,
		"npc": npc_name
	}
	# TODO: Реализовать сохранение
	print("Сохранено состояние диалога: ", save_data)

func load_dialogue_history():
	# TODO: Загрузить из сохранения
	pass
