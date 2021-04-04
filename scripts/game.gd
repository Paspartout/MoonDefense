class_name Game
extends Node2D

export var movement_speed: float = 0
onready var tween: Tween = $Tween

export var hud_path: NodePath
export var msg_box_path: NodePath
export var tutorial_path: NodePath
onready var msg_box: AnimationPlayer = get_node(msg_box_path).get_node("AnimationPlayer")
onready var hud = get_node(hud_path)
onready var tutorial: Tutorial = get_node(tutorial_path)

export var current_section: int = 1
export var skip_tutorial: bool = false

export(Array, PackedScene) var sections
onready var n_sections = sections.size()

const PlayerScene = preload("res://scenes/player.tscn")
var player: Player

func _get_configuration_warning():
	if hud_path.is_empty() or tutorial_path.is_empty():
		return "hud or tutorial path not set!"
	return ""

func _input(event):
	if Input.is_action_just_pressed("debug_hurt"):
		if is_instance_valid(player):
			print(player)
			player.hurt()
	if Input.is_action_just_pressed("debug_killall"):
		var enemies = get_tree().get_nodes_in_group("enemy")
		for enemy in enemies:
			enemy.hurt()

func start():
	player = setup_player($Player)
	player.controllable = true
	if skip_tutorial:
		tutorial_done()
		tutorial.queue_free()
	else:
		tutorial.start()
		tutorial.connect("done", self, "tutorial_done")	

func setup_player(player: Player):
	hud.set_player(player)
	player.connect("died", self, "death")
	#player.position = Vector2(100, 100)
	return player

func spawn_player():
	if is_instance_valid(player):
		push_warning("old player still valid!")
		# player.disconnect("died", self, "death")
	player = setup_player(PlayerScene.instance())
	player.position = Vector2(-100, 100)
	add_child(player)

func death():
	call_deferred("respawn_player")

func _process(delta):
	position.x += movement_speed * delta

func respawn_player():
	var lpf: AudioEffectLowPassFilter = AudioServer.get_bus_effect(1, 0)
	AudioServer.set_bus_effect_enabled(1, 0, true)
	tween.interpolate_property(lpf, "cutoff_hz", 20500, 100, 1,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	# Reverse parralax movement
	tween.interpolate_property($".", "movement_speed",
			200, -1000, 1,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property($CurrentSection, "position",
		$CurrentSection.position, $CurrentSection.position + Vector2(700, 0), 1,
		Tween.TRANS_QUAD, Tween.EASE_IN, 0.5)
	tween.start()
	
	yield(tween, "tween_all_completed")
	
	for c in $CurrentSection.get_children():
		c.queue_free()

	# Back To normal speed
	spawn_player()
	tween.interpolate_property($".", "movement_speed",
			-1000, 200, 1,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(lpf, "cutoff_hz", 100, 20500, 1,
	Tween.TRANS_QUAD, Tween.EASE_IN_OUT)

	tween.interpolate_property(player, "position",
		Vector2(-50, 140), Vector2(100, 140), 1,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

	yield(tween, "tween_all_completed")
	AudioServer.set_bus_effect_enabled(1, 0, false)

	$CurrentSection.position = Vector2(0, 0)
	load_section()

func tutorial_done():
	# Start Player/World Movement
	$MusicPlayer.play()
	tween.interpolate_property($".", "position",
			null, Vector2(0, 0), 1,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	# Start Player/World Movement
	tween.interpolate_property($".", "movement_speed",
			0, 200, 1,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

	yield(get_tree().create_timer(3.0), "timeout")
	load_section()

func load_section():
	var next_section = sections[current_section].instance()
	next_section.connect("cleared", self, "next_section")
	$CurrentSection.add_child(next_section)

func next_section():
	player.make_invul(3.0)
	msg_box.play("Success")
	current_section += 1
	yield(get_tree().create_timer(3.0), "timeout")
	if current_section >= n_sections:
		print("Game Over!")
		return
	load_section()


