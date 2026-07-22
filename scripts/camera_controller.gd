extends Camera2D

var shake_strength:=0.0
var shake_duration:=0.0
var shake_offset:=Vector2.ZERO

@export_group("look ahead")
@export var look_ahead_distance:=40.0
@export var look_ahead_speed:=2.0
@export var movement_threshold:=30.0

var look_ahead_offset:=Vector2.ZERO

func shake(strength:float,duration:float)->void:
	shake_strength=strength
	shake_duration=duration
	
func _process(delta: float) -> void:
	update_look_ahead(delta)
	update_shake(delta)
	
	
	offset=shake_offset+look_ahead_offset

func update_shake(delta:float)->void:
	if shake_duration>0.0:
		shake_duration-=delta
		
		shake_offset=Vector2(randf_range(-shake_strength,shake_strength),randf_range(-shake_strength,shake_strength))
	else:
		shake_offset=Vector2.ZERO
func update_look_ahead(delta:float)->void:
	var player := get_parent() as CharacterBody2D

	if player == null:
		return

	var target_x := 0.0

	if player.velocity.x > movement_threshold:
		target_x = look_ahead_distance
	elif player.velocity.x < -movement_threshold:
		target_x = -look_ahead_distance

	look_ahead_offset.x = lerp(look_ahead_offset.x,target_x,look_ahead_speed * delta)
