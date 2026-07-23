extends AnimatableBody2D

@onready var start_point: Marker2D = $startPoint
@onready var end_point: Marker2D = $endPoint

@export var speed:float=120.0
@export var wait_time:float=0.5

@export var start_offset: Vector2 = Vector2.ZERO
@export var end_offset: Vector2 = Vector2(300, 0)

var start_position:Vector2
var end_position:Vector2

var moving_to_end:=true
var waiting:=false

var intial_position:Vector2

func _ready() -> void:
	intial_position=position
	start_position = intial_position+start_offset
	end_position = intial_position+end_offset
	
func _physics_process(delta: float) -> void:
	var target:=end_position if moving_to_end else start_position
	position=position.move_toward(target,speed*delta)
	if position==target:
		moving_to_end=!moving_to_end
