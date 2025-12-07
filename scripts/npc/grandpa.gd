extends "res://scripts/npc/npc_base.gd"

func _ready():
	super._ready()
	
	# Дополнительная инициализация для Деда
	print("Дед инициализирован. Квестов: ", has_quest)

func get_start_node() -> String:
	# Особая логика для Деда
	if not has_spoken:
		return "first_meet"
	
	# Проверяем квесты игрока
	var quest_system = get_tree().get_first_node_in_group("quest_system")
	if quest_system and quest_system.has_method("has_completed_quest"):
		if quest_system.has_completed_quest("get_gun"):
			return "after_gunsmith"
		elif quest_system.has_active_quest("find_transmitter"):
			return "quest_in_progress"
	
	return super.get_start_node()

func on_dialogue_ended():
	# Особая логика после диалога с Дедом
	print("Диалог с Дедом завершен")
	# Можно дать предмет, активировать триггер и т.д.
