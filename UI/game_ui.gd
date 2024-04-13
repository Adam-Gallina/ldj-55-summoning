extends CanvasLayer

@export var BtnSelectedCol : Color
@export var BtnDefaultCol : Color

@onready var _pause_btn = get_node('%PauseBtn')
@onready var _play_btn = get_node('%PlayBtn')
@onready var _ff_btn = get_node('%FastForwardBtn')

@export var RerouteScene : PackedScene
@export var SplitterScene : PackedScene
@export var LaunchScene : PackedScene
@export var DelayScene : PackedScene
@export var DestroyScene : PackedScene
@export var TeleportScene : PackedScene

var _curr_drag : GridObject = null

@onready var _score_text = get_node('%ScoreLabel')

func _process(_delta):
    if Input.is_action_just_pressed("pause"):
        GridController.toggle_pause()

    if Input.is_action_just_pressed("fast forward"):
        GridController.toggle_fast_forward()

    _pause_btn.modulate = BtnSelectedCol if GridController.Paused else BtnDefaultCol
    _play_btn.modulate = BtnDefaultCol if GridController.FastForward else BtnSelectedCol
    _ff_btn.modulate = BtnSelectedCol if GridController.FastForward else BtnDefaultCol

    _score_text.text = str(ScoreBoard.get_score())


func _spawn_object(scene : PackedScene):
    var obj : GridObject = scene.instantiate()
    get_parent().add_child(obj)
    obj._dragged = true
    _on_object_drag_start(obj)

    obj.drag_start.connect(_on_object_drag_start)
    obj.drag_end.connect(_on_object_drag_end)

    return obj


func _on_pause_pressed():
    GridController.toggle_pause()

func _on_play_pressed():
    #if GridController.FastForward:
        GridController.toggle_fast_forward()

func _on_fast_forward_pressed():
    #if not GridController.FastForward:
        GridController.toggle_fast_forward()

func _on_spawn_pressed(obj):
    if _curr_drag != null:
        if not _on_trash_btn_pressed():
            return

    match obj:
        Constants.ObjectType.Reroute: return _spawn_object(RerouteScene)
        Constants.ObjectType.Splitter: return _spawn_object(SplitterScene)
        Constants.ObjectType.Launch: return _spawn_object(LaunchScene)
        Constants.ObjectType.Delay: return _spawn_object(DelayScene)
        Constants.ObjectType.Destroy: return _spawn_object(DestroyScene)
        Constants.ObjectType.Teleport: return _spawn_object(TeleportScene)

    printerr('Could not spawn object of type ', obj)


func _on_object_drag_start(obj : GridObject):
    _curr_drag = obj

func _on_object_drag_end(obj : GridObject):
    if obj == _curr_drag:
        _curr_drag = null

func _on_trash_btn_pressed():
    if _curr_drag != null:
        if _curr_drag.ObjType != Constants.ObjectType.None:
            _curr_drag.despawn()
            _curr_drag.drag_start.disconnect(_on_object_drag_start)
            _curr_drag.drag_end.disconnect(_on_object_drag_end)
            return true

        return false

    return true
