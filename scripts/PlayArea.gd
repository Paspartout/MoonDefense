extends Node2D

export var movement_speed: float = 0
onready var tween = $Tween

const AsteroidSection = preload("res://sections/AsteroidSection.tscn")
const EnemySpawner = preload("res://scenes/EnemySpawner.tscn")
const Player = preload("res://scenes/player.tscn")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	$Tutorial.connect("done", self, "tutorial_done")


func spawn_player():
	player = Player.instance()
	player.position = Vector2(100, 200)
	add_child(player)
	$HUD.set_player(player)
	player.connect("died", self, "death")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += movement_speed * delta

func death():
	tween.interpolate_property($".", "movement_speed",
			200, -1000, 2,
			Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(2), "timeout")
	tween.interpolate_property($".", "movement_speed",
			-1000, 200, 1,
			Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(1), "timeout")
	spawn_player()

func tutorial_done():
	$FxPlayer.play()
	tween.interpolate_property($".", "movement_speed",
			0, 200, 1,
			Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	asteroids_cleared()
	return

	var section = AsteroidSection.instance()
	section.connect("cleared", self, "asteroids_cleared")
	add_child(section)
	

func asteroids_cleared():
	var section = EnemySpawner.instance()
	add_child(section)
