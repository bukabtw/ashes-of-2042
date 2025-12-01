extends Node
class_name HealthComponent

@export var max_health: int = 100
var current_health: int

signal health_depleted()
signal damage_taken(amount: int)

func _ready():
	current_health = max_health
	print("HealthComponent инициализирован: ", current_health, "/", max_health)

func take_damage(amount: int):
	print("HealthComponent: получен урон ", amount)
	current_health -= amount
	current_health = max(0, current_health)
	
	damage_taken.emit(amount)
	print("HealthComponent: текущее здоровье ", current_health, "/", max_health)
	
	if current_health <= 0:
		print("HealthComponent: здоровье закончилось!")
		health_depleted.emit()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	print("HealthComponent: лечение ", amount, " HP: ", current_health, "/", max_health)
