extends PlayerState

var idle_timer: float = 0.0
var afk_cooldown: float = 10.0

func enter():
	player.velocity = Vector2.ZERO
	idle_timer = 0.0
	player.current_direction = player.last_movement_direction
	play_normal_idle()

func process_frame(delta):
	idle_timer += delta
	
	if idle_timer >= afk_cooldown:
		play_afk_animation()

func process_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
	
	if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
		state_machine.transition_to("move")

func play_normal_idle():
	var anim_name = "idle_" + get_direction_suffix()
	if player.animated_sprite.animation != anim_name:
		player.animated_sprite.play(anim_name)

func play_afk_animation():
	var afk_anim_name = "idle_afk_" + get_direction_suffix()
	
	if player.animated_sprite.sprite_frames.has_animation(afk_anim_name):
		player.animated_sprite.play(afk_anim_name)
		await player.animated_sprite.animation_finished
		
		# Сбрасываем таймер для следующего проигрывания через 2 минуты
		idle_timer = 0.0
	
	# Возвращаемся к обычному idle
	play_normal_idle()

func get_animation_name(direction: String) -> String:
	return "idle_" + direction

func play_animation():
	play_normal_idle()
