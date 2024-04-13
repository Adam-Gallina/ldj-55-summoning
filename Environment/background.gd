extends Node2D

@export var RotateSpeed = 1
@onready var _rotate_speed_rad = RotateSpeed * PI / 180

func _process(delta):
    $Pivot.rotation += _rotate_speed_rad * delta
    $Pivot/Images.rotation -= _rotate_speed_rad / 2 * delta