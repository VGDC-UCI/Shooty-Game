"""
Takes in inputs and inputs them into player behavior

Author: Srayan Jana, Kang Rui Yu
"""


extends Node2D

# States
var control_scheme: Dictionary = ControlSchemes.get_scheme_data(0)
var using_controller: bool = false
var training_mode: bool = false


func _physics_process(delta: float) -> void:
	get_input(delta)







