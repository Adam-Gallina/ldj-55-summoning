extends Sprite2D

@export var RotationSpeed : float = 5
@export var MaxRotation : float = 20
@onready var _half_rot = MaxRotation * PI / 180 / 2
@export var StartRotation : float = 0

@onready var _time = StartRotation

var _jiggling = false
var _jiggle_up = false
@export var JiggleDist : float = 20
@export var JiggleTime : float = .15
var _jiggle_start
var _jiggle_dir
var _jiggle_time

func _process(delta):
	_time += delta

	var d = sin(2 * PI * _time / RotationSpeed)
	rotation = d * _half_rot

	if _jiggling:
		_jiggle_time -= delta if not GridController.FastForward else (delta * 2)

		if _jiggle_up:
			var t = 1 - _jiggle_time / JiggleTime
			position = _jiggle_start + _jiggle_dir * t
			if t >= 1:
				_jiggle_up = false
				_jiggle_time = JiggleTime
		else:
			var t = _jiggle_time / JiggleTime
			position = _jiggle_start + _jiggle_dir * t
			if t <= 0:
				_jiggling = false
				position = _jiggle_start


func _on_portal_warning(_portal):
	jiggle()

func jiggle(delay=0):
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	if not is_instance_valid(self): return

	if get_child_count() > 0:
		get_children()[0].jiggle(.05)

	_jiggling = true
	_jiggle_up = true
	_jiggle_start = position
	_jiggle_dir = Vector2.RIGHT.rotated(randf() * 2 * PI) * JiggleDist
	_jiggle_time = JiggleTime
