class_name Section
extends Node2D

export var is_ground_section: bool = false
export var movement_speed = 200

# Sent when the section got cleared/is done
signal cleared()
