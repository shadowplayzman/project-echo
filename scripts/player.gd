extends CharacterBody2D


@export_group("Movement")
@export var max_speed: float=300.0
@export var acceleration: float=300.0
@export var deacceleration: float=300.0

func _physics_process(delta: float) -> void:
	move_horizontal(delta)
	move_and_slide()
	
func move_horizontal(delta:float)->void:
	var direction :=Input.get_axis("move_left","move_right")
	
	if direction!=0:
		velocity.x=move_toward(velocity.x,direction*max_speed,acceleration*delta)
	else:
		velocity.x=move_toward(velocity.x,0.0,deacceleration*delta)
		
