extends GridObject

@export var OutputScene : PackedScene
var _output : GridObject = null

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