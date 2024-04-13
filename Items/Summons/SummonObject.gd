extends Node2D
class_name SummonObject

var _curr_dir : Constants.Direction
var _last_hover = null
var _last_interaction = null

func set_movement_dir(dir : Constants.Direction): 
    _curr_dir = dir
    position = GridController.to_world_pos(GridController.closest_grid_space(position))

func get_movement_dir(): return _curr_dir

func _ready():
    GridController.step.connect(_on_step)

func _on_step(delta):
    var last_pos = position 
    position += Constants.DirectionVector(_curr_dir) * GridController.calc_move_speed() * delta

    var p = GridController.closest_grid_space(position)
    var o : GridObject = GridController.pos_contents(p)
    var center = GridController.to_world_pos(p)
    if o != null and last_pos.distance_to(center) <= last_pos.distance_to(position):
        if o != _last_interaction:
            _last_interaction = o
            o.summon_interact(self)

    if position.distance_to(center) < GridController.GridSize / 4:
        var s = GridController.pos_hovered(p)

        if s == null:
            GridController.hover(p, self)
            _last_hover = p
        elif s != self:
            s.on_collision(self)
    elif _last_hover != null and position.distance_to(_last_hover) >= GridController.GridSize / 4:
        GridController.unhover(_last_hover)
        _last_hover = null

func on_collision(other : SummonObject):
    GridController.unhover(_last_hover)
    queue_free()
    other.queue_free()