# dialogue_saver.gd
extends Node
class_name DialogueSaver

var save_path = "user://dialogue_save.json"

func save_dialogue_state():
	var save_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"npc_states": {}
	}
	
	# Собираем данные всех NPC
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if npc is NPCAdvanced:
			save_data["npc_states"][npc.npc_name] = {
				"dialogue_state": npc.dialogue_state,
				"dialogue_history": npc.dialogue_history
			}
	
	# Сохраняем в файл
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "  "))
		file.close()
		print("Сохранены состояния диалогов")

func load_dialogue_state():
	if not FileAccess.file_exists(save_path):
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if data and data.has("npc_states"):
			# Восстанавливаем состояния NPC
			var npcs = get_tree().get_nodes_in_group("npc")
			for npc in npcs:
				if npc is NPCAdvanced and data["npc_states"].has(npc.npc_name):
					var npc_data = data["npc_states"][npc.npc_name]
					npc.dialogue_state = npc_data.get("dialogue_state", 0)
					npc.dialogue_history = npc_data.get("dialogue_history", [])
			
			print("Загружены состояния диалогов")
