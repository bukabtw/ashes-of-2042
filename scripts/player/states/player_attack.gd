extends PlayerState

var attack_timer: float = 0.0
var attack_duration: float = 0.5

func get_animation_name(direction: String) -> String:
	return "attack_" + direction

func enter():
	player.velocity = Vector2.ZERO
	attack_timer = 0.0
	perform_attack()
	play_animation()

func perform_attack():
	print("\n=== ИГРОК АТАКУЕТ ===")
	var enemies = player.attack_range.get_overlapping_bodies()
	print("В зоне атаки: ", enemies.size(), " врагов")
	
	for body in enemies:
		print("Обнаружен: ", body.name, " (группы: ", body.get_groups(), ")")
		if body.is_in_group("enemies"):
			print("Наношу урон зомби: ", player.attack_damage)
			body.take_damage(player.attack_damage)
		else:
			print(body.name, " не в группе enemies")

func process_physics(delta):
	attack_timer += delta
	if attack_timer >= attack_duration:
		state_machine.transition_to("idle")
