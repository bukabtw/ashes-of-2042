extends Node
class_name NPCManager

var npc_registry: Dictionary = {}  # Имя NPC → ссылка на узел

func _ready():
	add_to_group("npc_manager")
	
	# Регистрируем всех NPC при старте
	register_all_npcs()

func register_all_npcs():
	var npcs = get_tree().get_nodes_in_group("npc")
	for npc in npcs:
		if npc is NPCBase:
			npc_registry[npc.npc_name] = npc
			print("Зарегистрирован NPC: ", npc.npc_name)

func get_npc(npc_name: String) -> NPCBase:
	return npc_registry.get(npc_name)

func set_npc_dialogue(npc_name: String, dialogue_node: String):
	var npc = get_npc(npc_name)
	if npc:
		npc.dialogue_start = dialogue_node

func trigger_npc_dialogue(npc_name: String):
	var npc = get_npc(npc_name)
	if npc:
		npc.start_dialogue()

func save_all_npc_states():
	for npc_name in npc_registry:
		var npc = npc_registry[npc_name]
		if npc and npc.has_method("save_dialogue_state"):
			npc.save_dialogue_state()
