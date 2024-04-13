extends Sprite2D

@export var RotationSpeed : float = 5
@export var MaxRotation : float = 20
@onready var _half_rot = MaxRotation * PI / 180 / 2
@export var StartRotation : float = 0

@onready var _time = StartRotation

func _process(delta):
    _time += delta

    var d = sin(2 * PI * _time / RotationSpeed)
    rotation = d * _half_rot
