extends Node2D

onready var timer: Timer = $LaserBeam/Timer
onready var sprite: Sprite = $LaserBeam/Beam
onready var beam: Area2D = $LaserBeam

export var on_time: float = 3
export var off_time: float = 3
export var start_offset: float = 1

func _ready():
	beam.connect("body_entered", self, "laser_hit")
	enable(false)
	timer.wait_time = start_offset
	timer.connect("timeout", self, "wait_over", [], CONNECT_ONESHOT)
	timer.start()

func wait_over():
	timer.connect("timeout", self, "turn_on", [], CONNECT_ONESHOT)
	timer.start()
	
func turn_on():
	enable(true)
	timer.wait_time = off_time
	timer.start()
	timer.connect("timeout", self, "turn_off", [], CONNECT_ONESHOT)

func turn_off():
	enable(false)
	timer.wait_time = on_time
	timer.start()
	timer.connect("timeout", self, "turn_on", [], CONNECT_ONESHOT)

func enable(on: bool):
	sprite.visible = on
	beam.monitoring = on

func laser_hit(body):
	if body.has_method("hurt"):
		body.hurt()
