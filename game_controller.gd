extends Node2D

@onready var _viewport_size = Vector2i(ProjectSettings.get_setting('display/window/size/viewport_width'), ProjectSettings.get_setting('display/window/size/viewport_height'))
@export var StartGridHeight : int = 7

@onready var portal_spawner = $PortalSpawner
@onready var game_ui = $PortalSpawner/GameUI

@onready var cam : Camera2D = $Camera2D
@onready var _curr_zoom : float = _calc_cam_zoom(StartGridHeight)
var _target_zoom : float
@onready var _target_grid_height : int = StartGridHeight

@export var CycleTime : float = 60
@onready var _cycle_tick_count : int = int(CycleTime / GridController.TickSpeed)
var _cycle_remaining : int = 0
var _zoom_remaining : float = -1

@export var MinTimeBetweenSpawns : int = 15
@onready var _min_tick_spawns : int = int(MinTimeBetweenSpawns / GridController.TickSpeed)
@export var MaxTimeBetweenSpawns : int = 25
@onready var _max_tick_spawns : int = int(MaxTimeBetweenSpawns / GridController.TickSpeed)
var _next_spawn : int = -1
@export var ChanceForNewOutput : float = .4
@export var ChanceForNewSeries : float = .25
@export var ChanceForNoNewInput : float = .35

var _series : Array[PortalSpawner.PortalSeries] = []

func _ready():
	GridController.step.connect(_on_step)
	GridController.tick.connect(_on_tick)
	
	_set_cam_zoom(_curr_zoom)
	GridController.update_grid_height(StartGridHeight)

	start_game()

func _set_cam_zoom(zoom : float):
	cam.zoom = Vector2(zoom, zoom)

func _calc_cam_zoom(grid_height : int):
	return float(_viewport_size.y) / float(grid_height * GridController.GridSize)


func start_game():
	GridController.toggle_pause()

	_series.append(portal_spawner.get_new_portal_series())
	var input_pos = portal_spawner.get_portal_spawn_pos()
	_series[0].inputs.append(portal_spawner.spawn_input_portal(_series[0], input_pos, 8))

	var output_pos = portal_spawner.get_portal_spawn_pos()
	_series[0].outputs.append(portal_spawner.spawn_output_portal(_series[0], output_pos))

	_next_spawn = randi_range(_min_tick_spawns, _max_tick_spawns)

func _on_step(delta, _to_next_tick):
	if _zoom_remaining == -1: return

	_zoom_remaining -= delta

	var zoom = _target_zoom
	if _zoom_remaining <= 0:
		_zoom_remaining = -1
		_curr_zoom = _target_zoom
		GridController.update_grid_height(_target_grid_height)
	else:
		var t = 1 - (_zoom_remaining / CycleTime)
		zoom = _curr_zoom + (_target_zoom - _curr_zoom) * t

	_set_cam_zoom(zoom)

func _on_tick():
	# Cycle tracking
	_cycle_remaining -= 1

	if _cycle_remaining <= 0:
		_cycle_remaining = _cycle_tick_count

		_target_grid_height += 2
		_target_zoom = _calc_cam_zoom(_target_grid_height)
		_zoom_remaining = CycleTime

	# Spawn tracking
	_next_spawn -= 1

	if _next_spawn == 0:
		var s : PortalSpawner.PortalSeries
		
		if portal_spawner.can_get_series() and randf() <= ChanceForNewSeries:
			s = portal_spawner.get_new_portal_series()
			_series.append(s)
			
			var output_pos = portal_spawner.get_portal_spawn_pos()
			s.outputs.append(portal_spawner.spawn_output_portal(s, output_pos))
		else:
			s = _series.pick_random()

			if randf() <= ChanceForNewOutput:
				var output_pos = portal_spawner.get_portal_spawn_pos()
				s.outputs.append(portal_spawner.spawn_output_portal(s, output_pos))
			else:
				pass # Make output bigger
		
		var input_pos = portal_spawner.get_portal_spawn_pos()
		s.inputs.append(portal_spawner.spawn_input_portal(s, input_pos))

		_next_spawn = randi_range(_min_tick_spawns, _max_tick_spawns)
