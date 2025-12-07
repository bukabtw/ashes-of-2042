# npc_simple_state.gd
extends Area2D
class_name NPCSimple

@export_category("Dialogue")
@export var npc_name: String = "npc"
@export var dialogue_file: String = "res://resources/dialogue/npc_dialogue.dialogue"

@export_category("States")
@export var start_node_first: String = "first_meet"    # Первый разговор
@export var start_node_repeat: String = "repeat"       # Повторный
@export var start_node_after_quest: String = "after_quest" # После "квеста"

@onready var animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var player_in_range: bool = false
var dialogue_resource: DialogueResource
var dialogue_state: int = 0  # 0=первый раз, 1=повтор, 2=после квеста
var has_given_item: bool = false  # Имитация выдачи предмета

func _ready():
	# Загружаем диалог
	dialogue_resource = load(dialogue_file)
	if not dialogue_resource:
		push_error("NPC %s: Не могу загрузить диалог %s" % [npc_name, dialogue_file])
	
	# Анимация
	if animated_sprite:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
	
	# Сигналы
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Загружаем сохраненное состояние (если есть)
	load_state()

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		start_dialogue()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		show_hint()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		hide_hint()

func start_dialogue():
	if not DialogueManager or not dialogue_resource:
		return
	
	# Определяем, какой диалог показывать
	var start_node = get_start_node()
	
	# Проигрываем анимацию (если есть)
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation("talk"):
			animated_sprite.play("talk")
	
	# Запускаем диалог
	DialogueManager.show_dialogue_balloon(dialogue_resource, start_node)
	
	# Обновляем состояние после диалога
	update_state_after_dialogue(start_node)

func get_start_node() -> String:
	match dialogue_state:
		0:  # Первый раз
			return start_node_first
		1:  # Повторный разговор
			return start_node_repeat
		2:  # После "квеста"
			return start_node_after_quest if start_node_after_quest else start_node_repeat
		_:
			return start_node_repeat

func update_state_after_dialogue(dialogue_node: String):
	# Если это был первый диалог - переключаем на повторный
	if dialogue_state == 0 and dialogue_node == start_node_first:
		dialogue_state = 1
		save_state()
	
	# Если диалог содержит маркер завершения квеста
	elif dialogue_node == "after_gunsmith" or dialogue_node.contains("complete"):
		dialogue_state = 2
		save_state()
	
	# Отмечаем, если "выдали" предмет
	if dialogue_node == "give_quest" and not has_given_item:
		has_given_item = true
		print("NPC %s: 'выдал' предмет (имитация)" % npc_name)
		save_state()

func show_hint():
	# Простая подсказка в консоли
	print("Нажми E поговорить с %s" % npc_name)
	# Можно добавить иконку или текст над NPC

func hide_hint():
	pass

func save_state():
	# Сохраняем в простую глобальную переменную
	var key = "npc_%s_state" % npc_name
	Global.set_data(key, {
		"dialogue_state": dialogue_state,
		"has_given_item": has_given_item,
		"timestamp": Time.get_unix_time_from_system()
	})

func load_state():
	# Загружаем из глобальной переменной
	var key = "npc_%s_state" % npc_name
	var data = Global.get_data(key)
	if data:
		dialogue_state = data.get("dialogue_state", 0)
		has_given_item = data.get("has_given_item", false)

# Простой глобальный менеджер данных
class Global:
	static var npc_data: Dictionary = {}
	
	static func set_data(key: String, value):
		npc_data[key] = value
	
	static func get_data(key: String):
		return npc_data.get(key)
