extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_icon: Sprite2D = $HeadIcon
@onready var body_icon: Sprite2D = $BodyIcon
@onready var legs_icon: Sprite2D = $LegsIcon
@onready var feet_icon: Sprite2D = $FeetIcon
@onready var backpack_icon: Sprite2D = $BackpackIcon
@onready var weapon_icon: Sprite2D = $WeaponIcon
@onready var medkit_icon: Sprite2D = $MedkitIcon
@onready var grenade_icon: Sprite2D = $GrenadeIcon
@onready var accessory_icon: Sprite2D = $AccessoryIcon

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	animated_sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	_load_player_frames()
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("idle_back"):
		animated_sprite.play("idle_back")

func _load_player_frames():
	var player_scene = load("res://scenes/player/player.tscn")
	if player_scene:
		var inst = player_scene.instantiate()
		var frames = inst.get_node_or_null("AnimatedSprite2D")
		if frames:
			animated_sprite.sprite_frames = frames.sprite_frames
		inst.queue_free()

func update_equipment(slot_type: int, item: ItemData):
	var tex: Texture2D = item.icon if item else null
	match slot_type:
		ItemData.EquipmentSlot.HEAD:
			head_icon.texture = tex
			head_icon.visible = tex != null
		ItemData.EquipmentSlot.BODY:
			body_icon.texture = tex
			body_icon.visible = tex != null
		ItemData.EquipmentSlot.LEGS:
			legs_icon.texture = tex
			legs_icon.visible = tex != null
		ItemData.EquipmentSlot.FEET:
			feet_icon.texture = tex
			feet_icon.visible = tex != null
		ItemData.EquipmentSlot.BACKPACK:
			backpack_icon.texture = tex
			backpack_icon.visible = tex != null
		ItemData.EquipmentSlot.MELEE, ItemData.EquipmentSlot.PISTOL, ItemData.EquipmentSlot.RIFLE:
			weapon_icon.texture = tex
			weapon_icon.visible = tex != null
		ItemData.EquipmentSlot.MEDKIT:
			medkit_icon.texture = tex
			medkit_icon.visible = tex != null
		ItemData.EquipmentSlot.GRENADE:
			grenade_icon.texture = tex
			grenade_icon.visible = tex != null
		ItemData.EquipmentSlot.RING:
			accessory_icon.texture = tex
			accessory_icon.visible = tex != null
