# npc_base.gd
extends Area2D
class_name NPCBase

@export_category("NPC Settings")
@export var npc_name: String = "npc"
@export var dialogue_file: String = "res://resources/dialogue/default.dialogue"
@export var dialogue_start: String = "start"
@export var repeat_start: String = "repeat"  # Для повторных разговоров
@export var has_quest: bool = false
@export var quest_id: String = ""

@export_category("Visual")
@export var idle_animation: String = "idle"
@export var talk_animation: String = "talk"

@onready var animated_sprite = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var interaction_icon = $InteractionIcon if has_node("InteractionIcon") else null

var player_in_range: bool = false
var dialogue_resource: DialogueResource
var has_spoken: bool = false  # Первый раз уже говорили?
var dialogue_history: Array = []

func _ready():
	# Загружаем диалог
	dialogue_resource = load(dialogue_file)
	if not dialogue_resource:
		push_error("NPC %s: Не могу загрузить диалог %s" % [npc_name, dialogue_file])
	
	# Анимация
	if animated_sprite and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(idle_animation):
		animated_sprite.play(idle_animation)
	
	# Сигналы
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Загружаем историю из сохранения
	load_dialogue_state()

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		start_dialogue()
	
	# Обновляем иконку взаимодействия
	update_interaction_icon()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func start_dialogue():
	if not DialogueManager or not dialogue_resource:
		push_error("Не могу начать диалог")
		return
	
	# Определяем, какой диалог показывать
	var start_node = get_start_node()
	
	# Проигрываем анимацию разговора
	play_talk_animation()
	
	# Запускаем диалог
	DialogueManager.show_dialogue_balloon(dialogue_resource, start_node)
	
	# Сохраняем факт разговора
	if not has_spoken:
		has_spoken = true
		save_dialogue_state()

func get_start_node() -> String:
	# Логика выбора узла диалога
	if not has_spoken:
		return dialogue_start  # Первый раз
	elif repeat_start and repeat_start != "":
		return repeat_start    # Повторный
	else:
		return dialogue_start  # По умолчанию

func play_talk_animation():
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation(talk_animation):
			animated_sprite.play(talk_animation)
		elif animated_sprite.sprite_frames.has_animation("talk"):
			animated_sprite.play("talk")

func update_interaction_icon(show: bool):
	if interaction_icon:
		interaction_icon.visible = show
		if show:
			# Запускаем простую анимацию через Tween
			var tween = create_tween().set_loops()
			tween.tween_property(interaction_icon, "position:y", -60.0, 1.0).from(-50.0).set_trans(Tween.TRANS_SINE)
			tween.tween_property(interaction_icon, "position:y", -50.0, 1.0).set_trans(Tween.TRANS_SINE)
		else:
			# Останавливаем твины на иконке (если есть)
			# Но create_tween по умолчанию привязан к SceneTree или Node, 
			# здесь проще просто скрыть, Tween сам умрет при удалении ноды или можно убить явно, 
			# но для простоты просто скрываем.
			pass

func mark_dialogue_shown(dialogue_id: String):
	if not dialogue_history.has(dialogue_id):
		dialogue_history.append(dialogue_id)
		save_dialogue_state()

func has_seen_dialogue(dialogue_id: String) -> bool:
	return dialogue_history.has(dialogue_id)

func save_dialogue_state():
	# Сохраняем в глобальный менеджер сохранений
	var save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager and save_manager.has_method("save_npc_state"):
		save_manager.save_npc_state(npc_name, {
			"has_spoken": has_spoken,
			"dialogue_history": dialogue_history
		})

func load_dialogue_state():
	# Загружаем из менеджера сохранений
	var save_manager = get_tree().get_first_node_in_group("save_manager")
	if save_manager and save_manager.has_method("load_npc_state"):
		var data = save_manager.load_npc_state(npc_name)
		if data:
			has_spoken = data.get("has_spoken", false)
			dialogue_history = data.get("dialogue_history", [])
