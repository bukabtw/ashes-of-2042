extends Resource
class_name ItemData

enum ItemType { MISC, WEAPON, ARMOR, CONSUMABLE }
enum EquipmentSlot { NONE, HEAD, BODY, LEGS, FEET, MELEE, PISTOL, RIFLE, BACKPACK, MEDKIT, GRENADE, RING }

@export var name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = false
@export var type: ItemType = ItemType.MISC
@export var equipment_slot: EquipmentSlot = EquipmentSlot.NONE

@export_group("Stats")
@export var armor_value: int = 0
@export var damage_value: int = 0
