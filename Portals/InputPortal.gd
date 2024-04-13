extends GridObject

@export var SummonedObject : PackedScene
@export var SummonRate : int = 2
@onready var _next_summon = SummonRate

var _summon_dir : Constants.Direction = Constants.Direction.Down

func _ready():
	GridController.tick.connect(_on_tick)

func _on_tick():
	_next_summon -= 1

	if _next_summon <= 0:
		var o = SummonedObject.instantiate()
		get_parent().add_child(o)
		o.position = position
		o.set_movement_dir(_summon_dir)

		_next_summon = SummonRate
