extends GridObject

var _last_summon : SummonObject = null
var _last_dir : Constants.Direction
var _tick = 0

func _ready():
    GridController.tick.connect(_on_tick)

func summon_interact(summon : SummonObject):
    _last_summon = summon
    _last_dir = summon.get_movement_dir()
    summon.set_movement_dir(Constants.Direction.None)
    _tick = 2

func _on_tick():
    if _last_summon != null and is_instance_valid(_last_summon):
        _tick -= 1
        if _tick <= 0:
            _last_summon.set_movement_dir(_last_dir)
            _last_summon = null
