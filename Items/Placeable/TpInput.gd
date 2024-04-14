extends GridObject

@export var OutputScene : PackedScene
var _output : GridObject = null
var _last_output_pos = null
var _last_pos = null
@onready var _line = $Line2D
@export var LinePoints = 50

func _ready():
    _line.points = []

func _process(delta):
    super(delta)

    if _output == null: return
    if _output.position == _last_output_pos and position == _last_pos: return


    var dir1 = Vector2.RIGHT
    var dir2 = Vector2.LEFT
    # Portals are adjacent
    if abs(_curr_grid_pos.x - _output._curr_grid_pos.x) <= 1 and abs (_curr_grid_pos.y - _output._curr_grid_pos.y) <= 1:
        dir1 = position.direction_to(_output.position)
        dir2 = -dir1
    # Portals are in line
    if _curr_grid_pos.x == _output._curr_grid_pos.x or _curr_grid_pos.y == _output._curr_grid_pos.y:
        dir1 = position.direction_to(_output.position)
        dir2 = -dir1        
    else:
        var d = position - _output.position
        var s = sign(d.x if abs(d.x) < abs(d.y) else d.y)

        dir1 = dir2.rotated(s * 90).normalized()
        dir2 = -dir1


    _line.points = _gen_points(Vector2(), dir1 * GridController.GridSize, _output.position - position, dir2 * GridController.GridSize, LinePoints)
    _last_output_pos = _output.position
    _last_pos = position


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



func _gen_points(p1:Vector2, c1:Vector2, p2:Vector2, c2:Vector2, points:int) -> Array[Vector2]:
    var m1 = p1 + c1
    var m2 = p2 + c2

    var ret : Array[Vector2] = []
    var step = 1. / (points-1)
    var t = 0
    for i in range(points):
        ret.append(_quad_bezier(p1, m1, m2, p2, t))
        t += step

    return ret

func _quad_bezier(p1:Vector2, p2:Vector2, p3:Vector2, p4:Vector2, t:float):
    var q0 = p1.lerp(p2, t)
    var q1 = p2.lerp(p3, t)
    var q2 = p3.lerp(p4, t)

    var r0 = q0.lerp(q1, t)
    var r1 = q1.lerp(q2, t)

    var s = r0.lerp(r1, t)
    return s