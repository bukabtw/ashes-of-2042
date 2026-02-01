extends CanvasLayer

@onready var health_bar = $RightBottom/VBoxContainer/HealthBar
@onready var armor_bar = $RightBottom/VBoxContainer/ArmorBar
@onready var ammo_label = $RightBottom/VBoxContainer/AmmoLabel
@onready var inventory_ui = $InventoryLayer/Inventory

# Слоты оружия
@onready var melee_icon = $BottomCenter/HBoxContainer/MeleeSlot/Icon
@onready var pistol_icon = $BottomCenter/HBoxContainer/PistolSlot/Icon
@onready var rifle_icon = $BottomCenter/HBoxContainer/RifleSlot/Icon

var player: CharacterBody2D
var inventory_data: InventoryData

func _ready():
	# HUD и инвентарь должны работать во время паузы
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	inventory_ui.visible = false
	ammo_label.text = ""

func setup_player(p_player: CharacterBody2D, p_inventory_data: InventoryData):
	player = p_player
	inventory_data = p_inventory_data
	
	# Подключаем здоровье
	if player.has_node("HealthComponent"):
		var health_comp = player.get_node("HealthComponent")
		health_bar.max_value = health_comp.max_health
		health_bar.value = health_comp.current_health
		if not health_comp.damage_taken.is_connected(_on_damage_taken):
			health_comp.damage_taken.connect(_on_damage_taken)
		if not health_comp.health_depleted.is_connected(_on_health_depleted):
			health_comp.health_depleted.connect(_on_health_depleted)
	
	# Подключаем инвентарь и экипировку
	inventory_ui.set_inventory_data(inventory_data)
	if not inventory_data.equipment_updated.is_connected(_on_equipment_updated):
		inventory_data.equipment_updated.connect(_on_equipment_updated)

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_inventory():
	inventory_ui.visible = !inventory_ui.visible
	get_tree().paused = inventory_ui.visible
	
	if inventory_ui.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_damage_taken(_amount: int):
	if player and player.has_node("HealthComponent"):
		health_bar.value = player.get_node("HealthComponent").current_health

func _on_health_depleted():
	print("HUD: Player died")

func _on_equipment_updated(slot: ItemData.EquipmentSlot, item: ItemData):
	# Обновляем иконки в HUD
	var icon_texture = item.icon if item else null
	
	match slot:
		ItemData.EquipmentSlot.MELEE:
			melee_icon.texture = icon_texture
		ItemData.EquipmentSlot.PISTOL:
			pistol_icon.texture = icon_texture
		ItemData.EquipmentSlot.RIFLE:
			rifle_icon.texture = icon_texture
	
	# Тут можно добавить логику отображения патронов, если взяли в руки огнестрел
	update_ammo_display()

func update_ammo_display():
	# Заглушка для патронов
	# В будущем нужно проверять текущее активное оружие
	ammo_label.text = "Ammo: --/--"
