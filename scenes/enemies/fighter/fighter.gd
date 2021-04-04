class_name EnemyTargeter
extends Enemy

export(FlightDirection) var direction = FlightDirection.UP
onready var opposite_direction = FlightDirection.UP if direction == FlightDirection.DOWN else FlightDirection.DOWN

export var shoot_start_delay: float = 1.0
export var between_burst_delay: float = 1.0

export var burst_delay: float = 0.1
export var burst_shots: int = 5

func act_coro():
	velocity.x = -movement_speed
	yield(wait_act(1), "completed")
	velocity.x = 0
	
	yield(move(FlightDirection.DOWN, 0.25), "completed")
	
	while true:
		yield(move(FlightDirection.UP, 0.5), "completed")
		yield(wait_act(0.5), "completed")
		yield(move(FlightDirection.DOWN, 0.5), "completed")

func shoot_coro():
	yield(wait_shoot(shoot_start_delay), "completed")
	while true:
		yield(shoot_burst(burst_shots, burst_delay, true), "completed")
		yield(wait_shoot(between_burst_delay), "completed")

func make_bullet():
	var bullet = .make_bullet()
	bullet.speed = 300
	return bullet
