extends GridObject

@export var OutputScene : PackedScene
var _output : GridObject = null
var _last_output_pos = null
@onready var _line = $Line2D
@export var LinePoints = 50

func _ready():
    _line.points = []

func _process(delta):
    super(delta)

    if _output == null: return
    if _output.position == _last_output_pos and not _dragged: return

    var dist = position.distance_to(_output.position)
    var step = dist / (LinePoints-1)
    var dir = position.direction_to(_output.position).normalized()
    var points = [Vector2()]
    for i in range(LinePoints-1):
        points.append(points[-1] + dir * step)
    _line.points = points

    _last_output_pos = _output.position


func _place_object(grid_pos : Vector2i):
    super(grid_pos)

    if _output == null:
        _output = get_parent().get_node('GameUI')._spawn_object(OutputScene)
        _output._dragged = true

func summon_interact(summon : SummonObject):
    if _output != null and not _output._dragged:
        summon.position = _output.position

func despawn():
    if _output != null: _output.queue_free()
    super()