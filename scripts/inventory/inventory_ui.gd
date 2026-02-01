extends Control

@export var inventory_data: InventoryData
var selected_tab: int = 0
var style_active: StyleBoxFlat
var style_inactive: StyleBoxFlat

# Основная сетка рюкзака
@onready var grid_container = $PanelContainer/MarginContainer/MainSection/Left/GridContainer

# Слоты экипировки
@onready var head_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/ArmorContainer/HeadSlot
@onready var body_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/ArmorContainer/BodySlot
@onready var legs_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/ArmorContainer/LegsSlot
@onready var feet_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/ArmorContainer/FeetSlot

@onready var melee_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/WeaponsContainer/MeleeSlot
@onready var pistol_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/WeaponsContainer/PistolSlot
@onready var rifle_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/WeaponsContainer/RifleSlot
@onready var backpack_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/WeaponsContainer/BackpackSlot

# Превью игрока
@onready var player_preview = $PanelContainer/MarginContainer/MainSection/Left/TopSection/PlayerPreviewContainer/PreviewFrame/PlayerPreview
@onready var player_preview_container = $PanelContainer/MarginContainer/MainSection/Left/TopSection/PlayerPreviewContainer/PreviewFrame
@onready var medkit_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/PlayerPreviewContainer/QuickSlots/MedkitSlot
@onready var grenade_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/PlayerPreviewContainer/QuickSlots/GrenadeSlot
@onready var accessory_slot = $PanelContainer/MarginContainer/MainSection/Left/TopSection/PlayerPreviewContainer/QuickSlots/AccessorySlot
@onready var quest_btn = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/TabsMargin/TabsBar/QuestBtn
@onready var stats_btn = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/TabsMargin/TabsBar/StatsBtn
@onready var skills_btn = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/TabsMargin/TabsBar/SkillsBtn
@onready var collection_btn = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/TabsMargin/TabsBar/CollectionBtn
@onready var quest_panel = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/Scroll/Content/QuestPanel
@onready var stats_panel = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/Scroll/Content/StatsPanel
@onready var skills_panel = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/Scroll/Content/SkillsPanel
@onready var collection_panel = $PanelContainer/MarginContainer/MainSection/Left/TopSection/RightPanel/Scroll/Content/CollectionPanel

const SlotUI = preload("res://scenes/inventory/inventory_slot.tscn")

func _ready():
	# Убеждаемся, что инвентарь работает во время паузы
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	style_active = StyleBoxFlat.new()
	style_active.bg_color = Color(0, 0, 0, 0)
	style_active.border_width_left = 0
	style_active.border_width_top = 0
	style_active.border_width_right = 0
	style_active.border_width_bottom = 2
	style_active.border_color = Color(1, 1, 1, 1)
	style_active.corner_radius_top_left = 0
	style_active.corner_radius_top_right = 0
	style_active.corner_radius_bottom_right = 0
	style_active.corner_radius_bottom_left = 0
	
	style_inactive = StyleBoxFlat.new()
	style_inactive.bg_color = Color(0, 0, 0, 0)
	style_inactive.border_width_left = 0
	style_inactive.border_width_top = 0
	style_inactive.border_width_right = 0
	style_inactive.border_width_bottom = 0
	style_inactive.border_color = Color(0.3, 0.3, 0.3, 1)
	style_inactive.corner_radius_top_left = 0
	style_inactive.corner_radius_top_right = 0
	style_inactive.corner_radius_bottom_right = 0
	style_inactive.corner_radius_bottom_left = 0
	
	quest_btn.pressed.connect(func(): _set_tab(0))
	stats_btn.pressed.connect(func(): _set_tab(1))
	skills_btn.pressed.connect(func(): _set_tab(2))
	collection_btn.pressed.connect(func(): _set_tab(3))
	
	var cfg := ConfigFile.new()
	var err = cfg.load("user://ui_settings.cfg")
	if err == OK and cfg.has_section_key("inventory", "selected_tab"):
		selected_tab = int(cfg.get_value("inventory", "selected_tab", 0))
	_set_tab(selected_tab)
	
	# Настраиваем превью игрока
	if player_preview:
		# Гарантируем работу превью даже на паузе
		player_preview.process_mode = Node.PROCESS_MODE_ALWAYS
		# Запускаем анимацию idle, если есть AnimatedSprite2D
		var anim_sprite = player_preview.get_node_or_null("AnimatedSprite2D")
		if anim_sprite:
			anim_sprite.play("idle_back")
	
	# Привязываем слоты экипировки к их типам для удобства
	_init_equipment_slot(head_slot, ItemData.EquipmentSlot.HEAD)
	_init_equipment_slot(body_slot, ItemData.EquipmentSlot.BODY)
	_init_equipment_slot(legs_slot, ItemData.EquipmentSlot.LEGS)
	_init_equipment_slot(feet_slot, ItemData.EquipmentSlot.FEET)
	_init_equipment_slot(melee_slot, ItemData.EquipmentSlot.MELEE)
	_init_equipment_slot(pistol_slot, ItemData.EquipmentSlot.PISTOL)
	_init_equipment_slot(rifle_slot, ItemData.EquipmentSlot.RIFLE)
	_init_equipment_slot(backpack_slot, ItemData.EquipmentSlot.BACKPACK)
	_init_equipment_slot(medkit_slot, ItemData.EquipmentSlot.MEDKIT)
	_init_equipment_slot(grenade_slot, ItemData.EquipmentSlot.GRENADE)
	_init_equipment_slot(accessory_slot, ItemData.EquipmentSlot.RING)
	
	if inventory_data:
		set_inventory_data(inventory_data)

func _set_tab(index: int):
	selected_tab = index
	var buttons = [quest_btn, stats_btn, skills_btn, collection_btn]
	for i in range(buttons.size()):
		var b = buttons[i]
		if b:
			b.button_pressed = (i == index)
			if i == index:
				b.add_theme_stylebox_override("normal", style_active)
				b.add_theme_stylebox_override("hover", style_active)
			else:
				b.add_theme_stylebox_override("normal", style_inactive)
				b.add_theme_stylebox_override("hover", style_inactive)
	
	var panels = [quest_panel, stats_panel, skills_panel, collection_panel]
	for i in range(panels.size()):
		var p = panels[i]
		if p:
			p.visible = (i == index)
	
	var cfg := ConfigFile.new()
	cfg.set_value("inventory", "selected_tab", index)
	cfg.save("user://ui_settings.cfg")

func _init_equipment_slot(slot_ui, slot_type):
	slot_ui.slot_index = -1 # Отрицательный индекс для экипировки
	slot_ui.slot_clicked.connect(func(_index, button): _on_equipment_slot_clicked(slot_type, button))

func set_inventory_data(data: InventoryData):
	if inventory_data:
		if inventory_data.inventory_updated.is_connected(populate_inventory):
			inventory_data.inventory_updated.disconnect(populate_inventory)
		if inventory_data.equipment_updated.is_connected(_on_equipment_updated):
			inventory_data.equipment_updated.disconnect(_on_equipment_updated)
			
	inventory_data = data
	
	if inventory_data:
		inventory_data.inventory_updated.connect(populate_inventory)
		inventory_data.equipment_updated.connect(_on_equipment_updated)
		populate_inventory(inventory_data)
		# Обновляем все слоты экипировки
		for slot_type in ItemData.EquipmentSlot.values():
			if slot_type != ItemData.EquipmentSlot.NONE:
				_update_equipment_slot_ui(slot_type, inventory_data.get_equipped_item(slot_type))

func populate_inventory(p_inventory_data: InventoryData):
	# Очищаем текущие слоты
	for child in grid_container.get_children():
		child.queue_free()
	
	# Создаем новые слоты (все 40, но блокируем недоступные)
	for i in range(p_inventory_data.MAX_SLOTS):
		var slot_ui = SlotUI.instantiate()
		grid_container.add_child(slot_ui)
		
		slot_ui.slot_index = i
		
		# Если слот доступен
		if i < p_inventory_data.unlocked_slots:
			slot_ui.slot_clicked.connect(_on_backpack_slot_clicked)
			
			if i < p_inventory_data.slots.size():
				var slot_data = p_inventory_data.slots[i]
				if slot_data:
					slot_ui.set_slot_data(slot_data)
				else:
					_clear_slot_ui(slot_ui)
		else:
			# Слот заблокирован
			slot_ui.set_locked(true)

func _clear_slot_ui(slot_ui):
	slot_ui.texture_rect.texture = null
	slot_ui.quantity_label.hide()
	slot_ui.tooltip_text = ""
	slot_ui.set_locked(false)

func _on_backpack_slot_clicked(index: int, button: int):
	# Логика взаимодействия с инвентарем
	# ПКМ - использовать/экипировать
	if button == MOUSE_BUTTON_RIGHT:
		var slot_data = inventory_data.slots[index]
		if slot_data and slot_data.item_data:
			var item = slot_data.item_data
			# Если предмет можно экипировать
			if item.equipment_slot != ItemData.EquipmentSlot.NONE:
				inventory_data.remove_item(item, 1)
				var returned_item = inventory_data.equip_item(item, item.equipment_slot)
				if returned_item:
					inventory_data.add_item(returned_item, 1)

func _on_equipment_slot_clicked(slot_type: ItemData.EquipmentSlot, button: int):
	# ПКМ или ЛКМ по слоту экипировки -> снять предмет
	if button == MOUSE_BUTTON_RIGHT or button == MOUSE_BUTTON_LEFT:
		var item = inventory_data.get_equipped_item(slot_type)
		if item:
			inventory_data.unequip_item(slot_type)
			var success = inventory_data.add_item(item, 1)
			if not success:
				inventory_data.equip_item(item, slot_type)
				print("Inventory full!")

func _on_equipment_updated(slot_type: ItemData.EquipmentSlot, item: ItemData):
	if player_preview:
		player_preview.update_equipment(slot_type, item)
	_update_equipment_slot_ui(slot_type, item)

func _update_equipment_slot_ui(slot_type: ItemData.EquipmentSlot, item: ItemData):
	var slot_ui = null
	match slot_type:
		ItemData.EquipmentSlot.HEAD: slot_ui = head_slot
		ItemData.EquipmentSlot.BODY: slot_ui = body_slot
		ItemData.EquipmentSlot.LEGS: slot_ui = legs_slot
		ItemData.EquipmentSlot.FEET: slot_ui = feet_slot
		ItemData.EquipmentSlot.MELEE: slot_ui = melee_slot
		ItemData.EquipmentSlot.PISTOL: slot_ui = pistol_slot
		ItemData.EquipmentSlot.RIFLE: slot_ui = rifle_slot
		ItemData.EquipmentSlot.BACKPACK: slot_ui = backpack_slot
		ItemData.EquipmentSlot.MEDKIT: slot_ui = medkit_slot
		ItemData.EquipmentSlot.GRENADE: slot_ui = grenade_slot
		ItemData.EquipmentSlot.RING: slot_ui = accessory_slot
	
	if slot_ui:
		if item:
			var temp_slot_data = SlotData.new()
			temp_slot_data.item_data = item
			temp_slot_data.quantity = 1
			slot_ui.set_slot_data(temp_slot_data)
		else:
			_clear_slot_ui(slot_ui)
