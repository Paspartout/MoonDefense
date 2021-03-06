extends Node2D

func pause():
	$AnimationPlayer.play("Appear")
	get_tree().paused = true

func _on_Continue_pressed():
	$AnimationPlayer.play("Disappear")
	get_tree().paused = false

func _on_Restart_pressed():
	get_tree().paused = false
	var player = get_tree().root.get_node("Game").player
	if player != null and is_instance_valid(player):
		player.kill()
	$AnimationPlayer.play("Disappear")

func _on_Menu_pressed():
	get_tree().paused = false
	for e in get_tree().get_nodes_in_group("enemy"):
		e.kill()
	var player = get_tree().root.get_node("Game").player
	if player != null and is_instance_valid(player):
		player.kill(true)
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().reload_current_scene()

func _on_Exit_pressed():
	get_tree().quit()
