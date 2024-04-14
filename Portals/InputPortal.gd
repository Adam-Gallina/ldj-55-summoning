extends GridObject

@export var SummonedObject : PackedScene
@export var SummonRate : int = 2
@onready var _next_summon = SummonRate

@onready var _progress_bar : TextureProgressBar = $TextureProgressBar
var _progress_dir = 1

var _summon_dir : Constants.Direction = Constants.Direction.Down

func set_summon_dir(dir : Constants.Direction):
	_summon_dir = dir

func set_summon_rate(rate : int):
	SummonRate = rate
	get_node('%EveryTwo').visible = rate == 2
	get_node('%EverySix').visible = rate == 2
	get_node('%EveryFour').visible = rate == 4 or rate == 2

func _ready():
	GridController.tick.connect(_on_tick)
	#GridController.step.connect(_on_step)

	_progress_bar.value = 0

func _on_tick():
	_next_summon -= 1

	if SummonRate > 0 and _next_summon <= 0:
		var o = SummonedObject.instantiate()
		get_parent().add_child(o)
		o.position = position
		o.set_movement_dir(_summon_dir)

		_next_summon = SummonRate
	
	_progress_bar.value += GridController.TickSpeed * _progress_dir

	if _progress_bar.value == _progress_bar.max_value:
		_progress_dir = -1
		_progress_bar.fill_mode = TextureProgressBar.FILL_COUNTER_CLOCKWISE
	elif _progress_bar.value == _progress_bar.min_value:
		_progress_dir = 1
		_progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE

#func _on_step(delta, _to_next_tick):
	#return
	#_progress_bar.value += delta * _progress_dir

	#if _progress_bar.value == _progress_bar.max_value:
	#	_progress_dir = -1
	#	_progress_bar.fill_mode = TextureProgressBar.FILL_COUNTER_CLOCKWISE
	#elif _progress_bar.value == _progress_bar.min_value:
	#	_progress_dir = 1
	#	_progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE