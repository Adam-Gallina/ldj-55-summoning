extends GridObject

var _launch_dir : Constants.Direction = Constants.Direction.Right

func rotate_cw():
    $Pivot/Sprite2D.rotation += PI/2
    _launch_dir = Constants.DirectionCW(_launch_dir)

func rotate_ccw():
    $Pivot/Sprite2D.rotation -= PI/2
    _launch_dir = Constants.DirectionCCW(_launch_dir)

func summon_interact(summon : SummonObject):
    summon.set_floating_tiles(3)
    summon.set_movement_dir(_launch_dir)
