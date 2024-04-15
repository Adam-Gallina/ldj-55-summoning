extends Node2D
class_name SummonObject

@export var ObjectNum : int
@export var MinRotationSpeed : float = 10
@export var MaxRotationSpeed : float = 30
@onready var _rotation_speed = (MinRotationSpeed + randf() * (MaxRotationSpeed-MinRotationSpeed)) * PI / 180
@onready var _rotation_dir = 1 if randi() % 2 == 0 else -1

var _curr_dir : Constants.Direction
var _last_hover = null
var _last_interaction = null
var _remaining_float = 0
var _last_float = null

@export var FloatScale : Vector2 = Vector2(1.35, 1.35)
var _float_anim_remaining

func set_movement_dir(dir : Constants.Direction): 
	_curr_dir = dir
	position = GridController.to_world_pos(GridController.closest_grid_space(position))

func get_movement_dir(): return _curr_dir

func set_floating_tiles(amount : int):
	_last_float = null
	_remaining_float = amount
	_float_anim_remaining = GridController.TickSpeed

func _ready():
	GridController.step.connect(_on_step)

func _on_step(delta, _to_next_tick):
	var last_pos = position 
	position += Constants.DirectionVector(_curr_dir) * GridController.calc_move_speed() * delta
	rotation += _rotation_speed * _rotation_dir * delta

	z_index = 1 if _remaining_float > 0 else 0
	if _remaining_float > 0:
		if _remaining_float <= 1 and _float_anim_remaining < GridController.TickSpeed:
			_float_anim_remaining += delta
			var t = 1 - _float_anim_remaining / GridController.TickSpeed
			scale = Vector2.ONE + (FloatScale - Vector2.ONE) * t
		elif _float_anim_remaining > 0:
			_float_anim_remaining -= delta
			var t = 1 - _float_anim_remaining / GridController.TickSpeed
			scale = Vector2.ONE + (FloatScale - Vector2.ONE) * t

	var p = GridController.closest_grid_space(position)

	if not GridController.is_in_bounds(p, 1):
		despawn()
		return

	var o : GridObject = GridController.pos_contents(p)
	var center = GridController.to_world_pos(p)
	if last_pos.distance_to(center) <= last_pos.distance_to(position):
		if _remaining_float > 0:
			if _last_float == null or _last_float != p:
				_remaining_float -= 1
				_last_float = p
		elif o != null and o != _last_interaction:
			_last_interaction = o
			o.summon_interact(self)

	if _remaining_float <= 0 and position.distance_to(center) < GridController.GridSize / 4:
		var s = GridController.pos_hovered(p)

		if s == null:
			GridController.hover(p, self)
			if _last_hover != null: GridController.unhover(_last_hover)
			_last_hover = p
		elif s != self:
			s.on_collision(self)
	elif _last_hover != null and position.distance_to(_last_hover) >= GridController.GridSize / 4:
		GridController.unhover(_last_hover)
		_last_hover = null

func on_collision(other : SummonObject):
	GridController.unhover(_last_hover)
	
	if not Constants.CollisionAudio:
		var a = $AudioStreamPlayer
		a.play()
		a.finished.connect(a.queue_free)
		remove_child(a)
		get_parent().add_child(a)

	despawn()
	other.despawn()

func despawn():
	GridController.step.disconnect(_on_step)
    
	if get_node('CPUParticles2D'):
		$CPUParticles2D.disconnect_particles(get_parent())

	queue_free()
