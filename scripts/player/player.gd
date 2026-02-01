extends CharacterBody2D

enum PlayerDirection { DOWN, UP, LEFT, RIGHT }
var current_direction: PlayerDirection = PlayerDirection.DOWN
var last_movement_direction: PlayerDirection = PlayerDirection.DOWN

@export var speed: int = 200
@export var attack_damage: int = 10
@export var is_preview: bool = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var head_armor_sprite = $AnimatedSprite2D/HeadArmorSprite
@onready var body_armor_sprite = $AnimatedSprite2D/BodyArmorSprite
@onready var legs_armor_sprite = $AnimatedSprite2D/LegsArmorSprite
@onready var feet_armor_sprite = $AnimatedSprite2D/FeetArmorSprite
@onready var backpack_sprite = $AnimatedSprite2D/BackpackSprite
@onready var weapon_sprite = $AnimatedSprite2D/WeaponSprite

@onready var attack_range = $AttackRange
@onready var state_machine = $PlayerStateMachine
@onready var health_component = $HealthComponent
@onready var camera = $Camera2D

const PlayerIdleState = preload("res://scripts/player/states/player_idle.gd")
const PlayerMoveState = preload("res://scripts/player/states/player_move.gd") 
const PlayerAttackState = preload("res://scripts/player/states/player_attack.gd")
const PlayerHurtState = preload("res://scripts/player/states/player_hurt.gd")
const PlayerDeathState = preload("res://scripts/player/states/player_death.gd")
const HUDScene = preload("res://scenes/ui/hud.tscn")

var inventory_data: InventoryData
var hud: CanvasLayer

func _ready():
	var collision = $CollisionShape2D
	collision.shape = RectangleShape2D.new()
	collision.shape.size = Vector2(24, 44)
	collision.position = Vector2(0, 10)

	if is_preview:
		process_mode = Node.PROCESS_MODE_ALWAYS
		if animated_sprite:
			animated_sprite.play("idle_back")
		return

	# Инициализация инвентаря
	inventory_data = InventoryData.new()
	inventory_data.slots.resize(InventoryData.MAX_SLOTS) # Используем константу
	inventory_data.equipment_updated.connect(update_equipment_visuals)
	
	# Настройка InputMap
	if not InputMap.has_action("inventory"):
		InputMap.add_action("inventory")
		var ev = InputEventKey.new()
		ev.keycode = KEY_I
		InputMap.action_add_event("inventory", ev)
		var ev_tab = InputEventKey.new()
		ev_tab.keycode = KEY_TAB
		InputMap.action_add_event("inventory", ev_tab)

	# Создание HUD
	hud = HUDScene.instantiate()
	call_deferred("_add_hud")

	if camera:
		camera.make_current()
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 4.0
		camera.zoom = Vector2(1.5, 1.5)
	
	var attack_range_node = $AttackRange
	if attack_range_node:
		attack_range_node.collision_layer = 1 << 3
		attack_range_node.collision_mask = 1 << 1
	
	setup_state_machine()
	
	if health_component:
		health_component.health_depleted.connect(_on_health_depleted)
	else:
		push_error("HealthComponent не найден!")

func _add_hud():
	if get_parent():
		get_parent().add_child(hud)
		hud.setup_player(self, inventory_data)

func setup_state_machine():
	var idle_state = PlayerIdleState.new()
	idle_state.setup_state(self, state_machine)
	
	var move_state = PlayerMoveState.new()
	move_state.setup_state(self, state_machine)
	
	var attack_state = PlayerAttackState.new()
	attack_state.setup_state(self, state_machine)
	
	var hurt_state = PlayerHurtState.new()
	hurt_state.setup_state(self, state_machine)
	
	var death_state = PlayerDeathState.new()
	death_state.setup_state(self, state_machine)
	
	state_machine.init_state("idle", idle_state)
	state_machine.init_state("move", move_state)
	state_machine.init_state("attack", attack_state)
	state_machine.init_state("hurt", hurt_state)
	state_machine.init_state("death", death_state)
	
	state_machine.transition_to("idle")

func _input(event):
	state_machine.process_input(event)

func _process(delta):
	if animated_sprite and animated_sprite.animation != "":
		_sync_equipment_animation(animated_sprite.animation, animated_sprite.frame)
	state_machine.process_frame(delta)

func _sync_equipment_animation(anim_name: String, frame_idx: int):
	# Sync all equipment sprites to main sprite
	var sprites = [head_armor_sprite, body_armor_sprite, legs_armor_sprite, feet_armor_sprite, backpack_sprite, weapon_sprite]
	for sprite in sprites:
		if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
			if sprite.animation != anim_name:
				sprite.play(anim_name)
			sprite.frame = frame_idx
		elif sprite:
			sprite.stop()
			sprite.frame = 0 # Or hide it if no animation

func update_equipment_visuals(slot_type: int, item_data: ItemData):
	var sprite_to_update = null
	match slot_type:
		ItemData.EquipmentSlot.HEAD: sprite_to_update = head_armor_sprite
		ItemData.EquipmentSlot.BODY: sprite_to_update = body_armor_sprite
		ItemData.EquipmentSlot.LEGS: sprite_to_update = legs_armor_sprite
		ItemData.EquipmentSlot.FEET: sprite_to_update = feet_armor_sprite
		ItemData.EquipmentSlot.BACKPACK: sprite_to_update = backpack_sprite
		ItemData.EquipmentSlot.MELEE, ItemData.EquipmentSlot.PISTOL, ItemData.EquipmentSlot.RIFLE:
			sprite_to_update = weapon_sprite
	
	if sprite_to_update:
		if item_data and item_data.icon: # Assuming item data will have sprite sheets later
			# For now, we don't have separate spritesheets for equipment.
			# This is where we would load the correct texture/resource based on item_data
			# e.g. sprite_to_update.sprite_frames = load(item_data.visual_path)
			sprite_to_update.show()
			pass
		else:
			sprite_to_update.hide()

func _physics_process(delta):
	state_machine.process_physics(delta)

func take_damage(damage: int):
	if health_component:
		health_component.take_damage(damage)
		
		flash_red()
		
		if state_machine.current_state and \
		   state_machine.current_state.name != "hurt" and \
		   state_machine.current_state.name != "death" and \
		   health_component.current_health > 0:
			state_machine.transition_to("hurt")

func flash_red():
	if not animated_sprite:
		return
	
	var original_modulate = animated_sprite.modulate
	animated_sprite.modulate = Color(1, 0.3, 0.3, 1)
	
	await get_tree().create_timer(0.1).timeout
	
	if animated_sprite:
		animated_sprite.modulate = original_modulate

func _on_health_depleted():
	print("Игрок умер!")
	state_machine.transition_to("death")

func die():
	print("Перезагрузка сцены...")
	get_tree().reload_current_scene()
