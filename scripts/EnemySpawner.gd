extends Node2D

const Enemy = preload("res://scenes/enemy.tscn")

var timer: Timer
onready var enemies = $Enemies
onready var spawn_points = $SpawnPoints.get_children()
var progress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.connect("timeout", self, "spawn")
	timer.autostart = true
	call_deferred("add_child", timer)
	


func spawn():
	var n_enemies = enemies.get_child_count()
	if n_enemies <= 0:
		if progress < spawn_points.size():
			print("spawn ", progress)
			var e = Enemy.instance()
			e.position = spawn_points[progress].position
			enemies.add_child(e)
			progress += 1
		else:
			print("Wave cleared!")
