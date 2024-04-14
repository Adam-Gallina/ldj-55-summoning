extends Node2D

@export var RotateSpeed = 1
@onready var _rotate_speed_rad = RotateSpeed * PI / 180

@export var PulseGradient : Gradient

var _pulse_tick = false

#func _ready():
    #GridController.step.connect(_on_step)
    #GridController.tick.connect(_on_tick)

func _process(delta):
    $Pivot.rotation += _rotate_speed_rad * delta
    $Pivot/Images.rotation -= _rotate_speed_rad / 2 * delta


func _on_step(_delta, time_to_tick):
    var t = time_to_tick / GridController.TickSpeed / 2
    if _pulse_tick:
        t += .5

    modulate = PulseGradient.sample(1 - t)

func _on_tick():
    _pulse_tick = not _pulse_tick