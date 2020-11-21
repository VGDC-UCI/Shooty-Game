"""
UI that has buttons for starting and ending a game.

Author: Kang Rui Yu
"""
extends Control

# Signals
signal start_pressed
signal exit_pressed


func onpressed_start() -> void:
	emit_signal("start_pressed")
	

func onpressed_exit() -> void:
	emit_signal("exit_pressed")