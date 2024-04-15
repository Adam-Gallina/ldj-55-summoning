extends Node2D

signal step(delta : float, to_next_tick : float)
signal tick()

const GridSize : int = 200
const TickSpeed = .5
@onready var _next_tick = TickSpeed

var Paused = false
var FastForward = false
const FastForwardSpeed : float = 2

var MinGrid : Vector2i = Vector2i(-5, -3)
var MaxGrid : Vector2i = Vector2i(5, 3)

var _curr_contained = {}
var _curr_hovered = {}

func update_grid_width(new_width : int):
	var x = float(new_width - 1) / 2
	var y = x - 2

	MinGrid = Vector2i(-int(x), -int(y))
	MaxGrid = Vector2i(int(x), int(y))

func update_grid_height(new_height : int):
	var y = float(new_height - 1) / 2
	var x = y + 2

	MinGrid = Vector2i(-int(x), -int(y))
	MaxGrid = Vector2i(int(x), int(y))

func update_grid(new_height : int, new_width : int):
	var y = float(new_height - 1) / 2
	var x = float(new_width - 1) / 2

	MinGrid = Vector2i(-int(x), -int(y))
	MaxGrid = Vector2i(int(x), int(y))
	print(MinGrid, ' ', MaxGrid)


func closest_grid_space(world_pos : Vector2) -> Vector2i:
	var x = int(world_pos.x + GridSize / 2 * sign(world_pos.x)) / GridSize
	var y = int(world_pos.y + GridSize / 2 * sign(world_pos.y)) / GridSize

	return Vector2i(x, y)

func get_mouse_grid_space() -> Vector2i:
	return closest_grid_space(get_global_mouse_position())

func to_world_pos(grid_pos : Vector2i):
	return grid_pos * GridSize

func pos_contents(grid_pos : Vector2i) -> GridObject:
	if is_instance_valid(_curr_contained.get(grid_pos)):
		return _curr_contained.get(grid_pos)
	return null

func insert(grid_pos : Vector2i, obj : GridObject):
	_curr_contained[grid_pos] = obj

func remove(grid_pos : Vector2i):
	_curr_contained.erase(grid_pos)

func is_in_bounds(grid_pos : Vector2i, margin=0):
	return grid_pos.x >= MinGrid.x-margin and grid_pos.x <= MaxGrid.x+margin and grid_pos.y >= MinGrid.y-margin and grid_pos.y <= MaxGrid.y+margin


func pos_hovered(grid_pos : Vector2i) -> SummonObject:
	if is_instance_valid(_curr_hovered.get(grid_pos)):
		return _curr_hovered.get(grid_pos)
	return null

func hover(grid_pos : Vector2i, obj : SummonObject):
	_curr_hovered[grid_pos] = obj

func unhover(grid_pos : Vector2i):
	_curr_hovered.erase(grid_pos)


func toggle_pause():
	Paused = not Paused

func toggle_fast_forward():
	FastForward = not FastForward


func _process(delta):
	if Paused: return

	_next_tick -= delta if not FastForward else (delta * FastForwardSpeed)
	if _next_tick <= 0:
		tick.emit()
		_next_tick = TickSpeed
	step.emit(delta if not FastForward else (delta * FastForwardSpeed), _next_tick)


func calc_move_speed():
	return GridSize / TickSpeed
