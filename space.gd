extends Control

func _ready() -> void:
	if OS.has_feature("android"):
		custom_minimum_size.y = 120
