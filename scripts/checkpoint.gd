extends Area2D

@onready var spawn_point: Marker2D = $SpawnPoint

var activated:=false



func _on_body_entered(body: Node2D) -> void:
	if activated:
		true
	if body.has_method("set_respawn_position"):
		body.set_respawn_position(spawn_point.global_position)
		activated=true
