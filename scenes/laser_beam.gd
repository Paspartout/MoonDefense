extends Node2D

onready var timer: Timer = $LaserBeam/Timer
onready var sprite: Sprite = $LaserBeam/Beam
onready var beam: Area2D = $LaserBeam

export var on_time: float = 3
export var off_time: float = 3
export var start_offset: float = 1

func _ready():
	act_coro()
	beam.connect("body_entered", self, "laser_hit")

func enable(on: bool):
	sprite.visible = on
	beam.monitoring = on

func act_coro():
	yield(wait(start_offset), "completed")
	while true:
		enable(false)
		yield(wait(on_time), "completed")
		enable(true)
		yield(wait(off_time), "completed")

func wait(time: float):
	timer.wait_time = time
	timer.start()
	yield(timer, "timeout")

func laser_hit(body):
	if body.has_method("hurt"):
		body.hurt()
