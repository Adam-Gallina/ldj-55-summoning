extends GridObject

var _input_dir = Constants.Direction.Down
var _output_dir = Constants.Direction.Right

func rotate_cw():
    $Pivot/Sprite2D.rotation += PI/2
    _input_dir = Constants.DirectionCW(_input_dir)
    _output_dir = Constants.DirectionCW(_output_dir)

func rotate_ccw():
    $Pivot/Sprite2D.rotation -= PI/2
    _input_dir = Constants.DirectionCCW(_input_dir)
    _output_dir = Constants.DirectionCCW(_output_dir)

func mirror():
    $Pivot/Sprite2D.scale.x *= -1
    _output_dir = Constants.DirectionInverse(_output_dir)


func summon_interact(summon : SummonObject):
    if summon.get_movement_dir() == _input_dir:
        summon.set_movement_dir(_output_dir)