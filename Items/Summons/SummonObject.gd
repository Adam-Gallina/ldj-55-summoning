extends Node2D
class_name SummonObject

var _curr_dir : Constants.Direction
var _last_hover = null
var _last_interaction = null
var _remaining_float = 0
var _last_float = null

func set_movement_dir(dir : Constants.Direction): 
    _curr_dir = dir
    position = GridController.to_world_pos(GridController.closest_grid_space(position))

func get_movement_dir(): return _curr_dir

func set_floating_tiles(amount : int):
    _remaining_float = amount

func _ready():
    GridController.step.connect(_on_step)

func _on_step(delta):
    var last_pos = position 
    position += Constants.DirectionVector(_curr_dir) * GridController.calc_move_speed() * delta

    var p = GridController.closest_grid_space(position)

    if not GridController.is_in_bounds(p):
        despawn()
        return

    var o : GridObject = GridController.pos_contents(p)
    var center = GridController.to_world_pos(p)
    if last_pos.distance_to(center) <= last_pos.distance_to(position):
        if _remaining_float > 0:
            if _last_float == null or _last_float != p:
                _remaining_float -= 1
                _last_float = p
        elif o != null and o != _last_interaction:
            _last_interaction = o
            o.summon_interact(self)

    if _remaining_float <= 0 and position.distance_to(center) < GridController.GridSize / 4:
        var s = GridController.pos_hovered(p)

        if s == null:
            GridController.hover(p, self)
            if _last_hover != null: GridController.unhover(_last_hover)
            _last_hover = p
        elif s != self:
            s.on_collision(self)
    elif _last_hover != null and position.distance_to(_last_hover) >= GridController.GridSize / 4:
        GridController.unhover(_last_hover)
        _last_hover = null

func on_collision(other : SummonObject):
    GridController.unhover(_last_hover)
    despawn()
    other.despawn()

func despawn():
    GridController.step.disconnect(_on_step)

    $CPUParticles2D.disconnect_particles(get_parent())

    queue_free()