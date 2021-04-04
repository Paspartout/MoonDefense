tool
class_name ScenesSection
extends Section

export(Array, PackedScene) var enemy_groups: Array
export var group_delay_time: float = 2.0

signal enemies_dead()

var timer: Timer
onready var enemies = $Enemies

var enemies_left = 0

func _get_configuration_warning():
	if enemy_groups.empty():
		return "No enemy group scenes set!"
	return ""

func _ready():
	if not Engine.editor_hint:
		wave()

func wave():
	for packed_group in enemy_groups:
		var group: Node2D = packed_group.instance()
		enemies_left = group.get_child_count()

		for enemy in group.get_children():
			enemy.connect("died", self, "enemy_died")
		$Enemies.add_child(group)
		yield(self, "enemies_dead")
		yield(get_tree().create_timer(group_delay_time), "timeout")

	emit_signal("cleared")

func enemy_died():
	enemies_left -= 1
	if enemies_left <= 0:
		enemies_left = 0
		emit_signal("enemies_dead")
