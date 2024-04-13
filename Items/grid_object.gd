extends Node2D
class_name GridObject

var _hovered = false
var _dragged = false

var _curr_grid_pos : Vector2i

func _process(_delta):
    if _dragged and Input.is_action_just_pressed('select'):
        _dragged = false
        GridController.insert(_curr_grid_pos, self)
    elif _dragged:
        if Input.is_action_just_pressed('rotate_cw'): rotate_cw()
        elif Input.is_action_just_pressed('rotate_ccw'): rotate_ccw()
        elif Input.is_action_just_pressed('mirror'): mirror()

        var pos = GridController.get_mouse_grid_space()

        if GridController.pos_contents(pos) == null:
            _curr_grid_pos = pos
            position = GridController.to_world_pos(pos)
    elif _hovered and Input.is_action_just_pressed('select'):
        _dragged = true
        
        if GridController.pos_contents(_curr_grid_pos) == self:
            GridController.remove(_curr_grid_pos)

func rotate_ccw(): pass
func rotate_cw(): pass
func mirror(): pass

func summon_interact(_summon : SummonObject):
    pass


func _on_mouse_entered():
    _hovered = true

func _on_mouse_exited():
    _hovered = false