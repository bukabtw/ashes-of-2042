extends Node
class_name QuestSystem

signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_updated(quest_id: String, progress: int)

var active_quests: Dictionary = {}
var completed_quests: Array = []
var inventory: Array = []

func _ready():
	add_to_group("quest_system")

func start_quest(quest_id: String, quest_data: Dictionary):
	if not active_quests.has(quest_id):
		active_quests[quest_id] = {
			"data": quest_data,
			"progress": 0,
			"objectives": quest_data.get("objectives", []),
			"started_at": Time.get_unix_time_from_system()
		}
		quest_started.emit(quest_id)
		print("Квест начат: ", quest_id)

func complete_quest(quest_id: String):
	if active_quests.has(quest_id):
		var quest = active_quests[quest_id]
		completed_quests.append(quest_id)
		active_quests.erase(quest_id)
		quest_completed.emit(quest_id)
		print("Квест завершен: ", quest_id)
		
		# Оповещаем NPC
		update_npc_dialogues(quest_id)

func update_quest_progress(quest_id: String, progress: int):
	if active_quests.has(quest_id):
		active_quests[quest_id]["progress"] = progress
		quest_updated.emit(quest_id, progress)

func has_quest(quest_id: String) -> bool:
	return active_quests.has(quest_id) or completed_quests.has(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.has(quest_id)

func add_item(item_id: String):
	if not inventory.has(item_id):
		inventory.append(item_id)
		print("Добавлен предмет: ", item_id)
		
		# Проверяем квесты, связанные с предметом
		check_item_quests(item_id)

func has_item(item_id: String) -> bool:
	return inventory.has(item_id)

func check_item_quests(item_id: String):
	# Проверяем, не завершает ли предмет какой-то квест
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		if quest["data"].has("required_items") and quest["data"]["required_items"].has(item_id):
			complete_quest(quest_id)

func update_npc_dialogues(quest_id: String):
	# Находим всех NPC и обновляем их диалоги
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if npc is NPCAdvanced:
			if npc.npc_name == "grandpa" and quest_id == "get_gun":
				npc.complete_quest()
