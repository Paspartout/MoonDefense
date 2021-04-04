extends Section

export(PackedScene) var Enemy
export(Array, PackedScene) var enemy_groups

signal enemies_dead()

var timer: Timer
onready var enemies = $Enemies

var enemies_left = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	wave()

func wave():
	for packed_group in enemy_groups:
		var group: Node2D = packed_group.instance()
		enemies_left = group.get_child_count()

		for enemy in group.get_children():
			enemy.connect("died", self, "enemy_died")
		$Enemies.add_child(group)
		yield(self, "enemies_dead")

	emit_signal("cleared")

func enemy_died():
	enemies_left -= 1
	print("enemies_left ", enemies_left)
	if enemies_left <= 0:
		enemies_left = 0
		emit_signal("enemies_dead")
