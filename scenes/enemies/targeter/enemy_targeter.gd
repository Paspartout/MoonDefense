class_name EnemyTargeter
extends Enemy

var additional_delay = 0.0
var trailing_delay = 0.0

func _ready():
	print("Targeter here")

func init(delay):
	additional_delay = delay

func act_coro():
	velocity.x = -movement_speed
	yield(wait_act(1), "completed")
	velocity.x = 0

func shoot_coro():
	while true:
		yield(wait_shoot(1.5 + additional_delay), "completed")
		shoot_at_player()
		yield(wait_shoot(0.1), "completed")
		shoot_at_player()
		yield(wait_shoot(0.1), "completed")
		shoot_at_player()
		if trailing_delay > 0:
			yield(wait_shoot(trailing_delay), "completed")

func make_bullet():
	var bullet = .make_bullet()
	bullet.speed = 400
	return bullet
