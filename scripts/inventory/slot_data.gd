extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 99

@export var item_data: ItemData
@export var quantity: int = 1: set = set_quantity

func set_quantity(value: int):
	quantity = value
	if quantity > 1 and not item_data.stackable:
		quantity = 1
		push_error("Предмет %s не стакается, quantity сброшено на 1" % item_data.name)

func can_merge_with(other_slot: SlotData) -> bool:
	return item_data == other_slot.item_data and item_data.stackable and quantity < MAX_STACK_SIZE

func merge_with(other_slot: SlotData):
	if not can_merge_with(other_slot):
		return
	
	var total = quantity + other_slot.quantity
	if total <= MAX_STACK_SIZE:
		quantity = total
		other_slot.quantity = 0
	else:
		quantity = MAX_STACK_SIZE
		other_slot.quantity = total - MAX_STACK_SIZE
