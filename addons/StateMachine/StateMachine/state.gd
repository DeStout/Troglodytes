class_name State extends Node


signal transition
var active := false

var character : CharacterBody3D


func enter() -> void: pass
func exit() -> void: pass
func update(delta) -> void: pass
func physics_update(delta) -> void: pass
