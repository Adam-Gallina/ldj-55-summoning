extends Node2D
class_name GridObject

signal drag_start(obj : GridObject)
signal drag_end(obj : GridObject)

@export var ObjType : int

var _hovered = false
var _dragged = false

var _curr_grid_pos : Vector2i

func _process(_delta):
    #if _dragged and Input.is_action_just_pressed('select'):
    #    _dragged = false
    #    _place_object(_curr_grid_pos)
    #elif _dragged:
    if _dragged:
        if Input.is_action_just_pressed('rotate_cw'): rotate_cw()
        elif Input.is_action_just_pressed('rotate_ccw'): rotate_ccw()
        elif Input.is_action_just_pressed('mirror'): mirror()

        var pos = GridController.get_mouse_grid_space()

        if GridController.pos_contents(pos) == null:
            _curr_grid_pos = pos
            position = GridController.to_world_pos(pos)
    #elif _hovered and Input.is_action_just_pressed('select'):
    #    _dragged = true
        
    #    if GridController.pos_contents(_curr_grid_pos) == self:
    #        GridController.remove(_curr_grid_pos)

func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not event.is_echo():
            if _dragged:
                _dragged = false
                drag_end.emit(self)
                _place_object(_curr_grid_pos)
            elif _hovered:
                _dragged = true
                drag_start.emit(self)
                
                if GridController.pos_contents(_curr_grid_pos) == self:
                    GridController.remove(_curr_grid_pos)


func _place_object(grid_pos : Vector2i):
    GridController.insert(grid_pos, self)


func rotate_ccw(): pass
func rotate_cw(): pass
func mirror(): pass

func summon_interact(_summon : SummonObject):
    pass

func despawn():
    queue_free()


func _on_mouse_entered():
    _hovered = true

func _on_mouse_exited():
    _hovered = false