extends Resource
class_name InventoryData

signal inventory_updated(inventory_data: InventoryData)
signal inventory_interact(inventory_data: InventoryData, index: int, button: int)
signal equipment_updated(slot: ItemData.EquipmentSlot, item: ItemData)

const MAX_SLOTS = 40
const DEFAULT_SLOTS = 10

@export var slots: Array[SlotData]
# Словарь для хранения экипировки: EquipmentSlot -> SlotData
@export var equipment: Dictionary = {}

var unlocked_slots: int = DEFAULT_SLOTS

func _init():
	# Инициализируем словарь экипировки пустыми значениями
	for slot_type in ItemData.EquipmentSlot.values():
		if slot_type != ItemData.EquipmentSlot.NONE:
			equipment[slot_type] = null

func add_item(item: ItemData, quantity: int = 1) -> bool:
	# 1. Пытаемся добавить в существующие стаки (только в рюкзаке)
	if item.stackable:
		for i in range(unlocked_slots):
			if i < slots.size():
				var slot = slots[i]
				if slot and slot.item_data == item and slot.quantity < slot.MAX_STACK_SIZE:
					var available_space = slot.MAX_STACK_SIZE - slot.quantity
					var to_add = min(quantity, available_space)
					slot.quantity += to_add
					quantity -= to_add
					inventory_updated.emit(self)
					if quantity == 0:
						return true
	
	# 2. Добавляем в первый пустой слот (в пределах разблокированных)
	for i in range(unlocked_slots):
		if i < slots.size():
			if not slots[i]: # Если слот пустой
				var new_slot = SlotData.new()
				new_slot.item_data = item
				new_slot.quantity = quantity
				slots[i] = new_slot
				inventory_updated.emit(self)
				return true
	
	return false

func remove_item(item: ItemData, quantity: int = 1) -> bool:
	if get_item_count(item) < quantity:
		return false
		
	var remaining_to_remove = quantity
	
	for i in range(slots.size()):
		var slot = slots[i]
		if slot and slot.item_data == item:
			if slot.quantity >= remaining_to_remove:
				slot.quantity -= remaining_to_remove
				remaining_to_remove = 0
				if slot.quantity == 0:
					slots[i] = null
				inventory_updated.emit(self)
				return true
			else:
				remaining_to_remove -= slot.quantity
				slots[i] = null
	
	inventory_updated.emit(self)
	return true

func get_item_count(item: ItemData) -> int:
	var count = 0
	for slot in slots:
		if slot and slot.item_data == item:
			count += slot.quantity
	return count

# Методы для экипировки
func equip_item(item: ItemData, slot_type: ItemData.EquipmentSlot) -> ItemData:
	# Возвращает предыдущий предмет, если он был
	var previous_item = null
	
	if equipment.has(slot_type) and equipment[slot_type] != null:
		previous_item = equipment[slot_type].item_data
	
	var new_slot = SlotData.new()
	new_slot.item_data = item
	new_slot.quantity = 1
	equipment[slot_type] = new_slot
	
	equipment_updated.emit(slot_type, item)
	return previous_item

func unequip_item(slot_type: ItemData.EquipmentSlot) -> ItemData:
	if equipment.has(slot_type) and equipment[slot_type] != null:
		var item = equipment[slot_type].item_data
		equipment[slot_type] = null
		equipment_updated.emit(slot_type, null)
		return item
	return null

func get_equipped_item(slot_type: ItemData.EquipmentSlot) -> ItemData:
	if equipment.has(slot_type) and equipment[slot_type] != null:
		return equipment[slot_type].item_data
	return null

func on_slot_clicked(index: int, button: int):
	# Проверка на границы доступных слотов
	if index < unlocked_slots:
		inventory_interact.emit(self, index, button)

func unlock_slots(amount: int):
	unlocked_slots = min(unlocked_slots + amount, MAX_SLOTS)
	# Увеличиваем размер массива, если нужно, но у нас он будет фиксирован 40, просто логически ограничим
	inventory_updated.emit(self)
