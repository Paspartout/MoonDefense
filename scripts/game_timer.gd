extends Panel

var time_s: int = 0

onready var label = $TimeLabel

func _ready():
	pass # Replace with function body.

func _on_Timer_timeout():
	time_s += 1
	label.text = "%02d:%02d" % [time_s / 60, time_s % 60]
