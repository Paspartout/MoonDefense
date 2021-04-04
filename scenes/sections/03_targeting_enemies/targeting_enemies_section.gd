extends Section

export(PackedScene) var Enemy

signal enemies_dead()

var timer: Timer
onready var enemies = $Enemies
onready var spawn_points = $SpawnPoints.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.connect("timeout", self, "check_enemies")
	timer.autostart = true
	call_deferred("add_child", timer)
	wave()

func wave():
	spawn(0, 0)
	yield(self, "enemies_dead")
	spawn(1, 0)
	spawn(2, 0.5)
	yield(self, "enemies_dead")
	spawn(0, 0)
	spawn(1, 1)
	spawn(2, 2)
	yield(self, "enemies_dead")
	emit_signal("cleared")


func check_enemies():
	var n_enemies = enemies.get_child_count()
	if n_enemies <= 0:
		emit_signal("enemies_dead")

func spawn(spawnpoint: int, delay: float):
	var e: Enemy = Enemy.instance()
	e.init(delay)
	e.position = spawn_points[spawnpoint].position
	enemies.add_child(e)
