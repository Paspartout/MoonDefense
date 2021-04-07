class_name FigherTurrent
extends Enemy

export var between_burst_delay: float = 1.0
export var burst_delay: float = 0.1
export var burst_shots: int = 5

var shoot = false

func shoot_coro():
	while true:
		if dead:
			return
		yield(wait_shoot(0.5), "completed")
		if shoot:
			yield(shoot_burst(burst_shots, burst_delay, true), "completed")
			yield(wait_shoot(between_burst_delay), "completed")

func make_bullet():
	var bullet = .make_bullet()
	bullet.position = position
	bullet.speed = 250
	return bullet

func _on_ShootRadius_body_entered(_body):
	shoot = true

func _on_ShootRadius_body_exited(_body):
	shoot = false

func shoot_at_player():
	var b = make_bullet()
	var player = get_tree().root.get_node("Game").player
	if is_instance_valid(player):
		var random_offset = Vector2(rand_range(-accuracy, accuracy), rand_range(-accuracy, accuracy))
		b.shoot(global_position.direction_to(player.global_position + random_offset))
	else:
		b.shoot(Vector2.LEFT)

	if velocity.x < 0:
		b.velocity.x += velocity.x
	get_parent().add_child(b)
