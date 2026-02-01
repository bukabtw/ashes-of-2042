extends PanelContainer

signal slot_clicked(index: int, button: int)

@onready var texture_rect = $MarginContainer/TextureRect
@onready var quantity_label = $MarginContainer/Label
@onready var lock_label = $MarginContainer/LockLabel

var slot_index: int = -1

func set_slot_data(slot_data: SlotData):
	var item_data = slot_data.item_data
	texture_rect.texture = item_data.icon
	tooltip_text = "%s\n%s" % [item_data.name, item_data.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
		quantity_label.show()
	else:
		quantity_label.hide()
	
	set_locked(false)

func set_locked(locked: bool):
	if locked:
		lock_label.show()
		texture_rect.hide()
		quantity_label.hide()
		modulate = Color(0.5, 0.5, 0.5, 0.8)
		tooltip_text = "Купить новый рюкзак можно у главных NPC на локации"
	else:
		lock_label.hide()
		texture_rect.show()
		modulate = Color(1, 1, 1, 1)
		# Tooltip resets in set_slot_data or clear

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		slot_clicked.emit(slot_index, event.button_index)
