extends Node2D

signal game_over(score : int)

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
@export var ChanceForNewOutput : float = .25
@export var ChanceForNewSeries : float = .35
@export var ChanceForNoNewInput : float = .35

var _series : Array[PortalSpawner.PortalSeries] = []

func _ready():
	GridController.step.connect(_on_step)
	GridController.tick.connect(_on_tick)

	game_over.connect(get_node('%GameUI')._on_game_lost)
	
	_set_cam_zoom(_curr_zoom)
	GridController.update_grid_height(StartGridHeight)

	start_game()

func _set_cam_zoom(zoom : float):
	cam.zoom = Vector2(zoom, zoom)

func _calc_cam_zoom(grid_height : int):
	return float(_viewport_size.y) / float(grid_height * GridController.GridSize)


func start_game():
	Leaderboard.start_new_game()
	GridController.toggle_pause()

	_series.append(portal_spawner.get_new_portal_series())
	var input_pos = portal_spawner.get_portal_spawn_pos()
	_series[0].inputs.append(portal_spawner.spawn_input_portal(_series[0], input_pos, 8))
	_series[0].input_rate += 1

	var output_pos = portal_spawner.get_portal_spawn_pos()
	_series[0].outputs.append(portal_spawner.spawn_output_portal(_series[0], output_pos, 8))
	_series[0].outputs[-1].portal_filled.connect(_on_portal_filled)
	_series[0].output_rate += 1

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
		var spawn_successful = false


		var s : PortalSpawner.PortalSeries
		
		if portal_spawner.can_get_series() and randf() <= ChanceForNewSeries:
			s = portal_spawner.get_new_portal_series()
			_series.append(s)
		else:
			s = _series.pick_random()

		var eligible_upgrades = []
		for out in s.outputs:
			if out.EmptyRate == 1:
				continue
			if s.input_rate - s.output_rate >= 8 / out.EmptyRate:
				eligible_upgrades.append(out)


		if eligible_upgrades.size() == 0 or randf() <= ChanceForNewOutput:
			var input_pos = portal_spawner.get_portal_spawn_pos()
			var output_pos = portal_spawner.get_portal_spawn_pos()

			if input_pos != null and output_pos != null:
				s.inputs.append(portal_spawner.spawn_input_portal(s, input_pos))
				s.input_rate += int(8 / s.inputs[-1].SummonRate)
				
				s.outputs.append(portal_spawner.spawn_output_portal(s, output_pos, 8))
				s.outputs[-1].portal_filled.connect(_on_portal_filled)
				s.output_rate += 1

				spawn_successful = true		
		else:
			var upgrade = eligible_upgrades.pick_random()

			if upgrade.EmptyRate == 8:
				upgrade.set_empty_rate(4)
				s.output_rate += 1
			elif upgrade.EmptyRate == 4:
				upgrade.set_empty_rate(2)
				s.output_rate += 2
			elif upgrade.EmptyRate == 2:
				upgrade.set_empty_rate(1)
				s.output_rate += 4

			if not randf() <= ChanceForNewOutput:
				var input_pos = portal_spawner.get_portal_spawn_pos()
				if input_pos != null:
					s.inputs.append(portal_spawner.spawn_input_portal(s, input_pos))
					s.input_rate += int(8 / s.inputs[-1].SummonRate)
			
			spawn_successful = true
		
		if spawn_successful: _next_spawn = randi_range(_min_tick_spawns, _max_tick_spawns)


func _on_portal_filled(_portal):
	Leaderboard.end_game()
	game_over.emit(Leaderboard.get_curr_score())