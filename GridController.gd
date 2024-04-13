extends Node2D

signal step(delta : float)
signal tick()

const GridSize : int = 200
const TickSpeed = .5
@onready var _next_tick = TickSpeed

var _curr_contained = {}
var _curr_hovered = {}

func closest_grid_space(world_pos : Vector2) -> Vector2i:
	var x = int(world_pos.x + GridSize / 2 * sign(world_pos.x)) / GridSize
	var y = int(world_pos.y + GridSize / 2 * sign(world_pos.y)) / GridSize

	return Vector2i(x, y)

func get_mouse_grid_space() -> Vector2i:
	return closest_grid_space(get_global_mouse_position())

func to_world_pos(grid_pos : Vector2i):
	return grid_pos * GridSize

func pos_contents(grid_pos : Vector2i) -> GridObject:
	return _curr_contained.get(grid_pos)

func insert(grid_pos : Vector2i, obj : GridObject):
	_curr_contained[grid_pos] = obj

func remove(grid_pos : Vector2i):
	_curr_contained.erase(grid_pos)


func pos_hovered(grid_pos : Vector2i) -> SummonObject:
	if is_instance_valid(_curr_hovered.get(grid_pos)):
		return _curr_hovered.get(grid_pos)
	return null

func hover(grid_pos : Vector2i, obj : SummonObject):
	_curr_hovered[grid_pos] = obj

func unhover(grid_pos : Vector2i):
	_curr_hovered.erase(grid_pos)


func _process(delta):
	step.emit(delta)

	_next_tick -= delta
	if _next_tick <= 0:
		tick.emit()
		_next_tick = TickSpeed


func calc_move_speed():
	return GridSize / TickSpeed
