extends Node2D

@onready var interaction_icon = $InteractionIcon
@onready var npc = get_parent()

func _ready():
	interaction_icon.hide()

func _process(_delta):
	if npc.player_in_range:
		interaction_icon.show()
		# Плавное покачивание
		interaction_icon.position.y = sin(Time.get_ticks_msec() * 0.005) * 5
	else:
		interaction_icon.hide()
