extends Node2D
class_name PortalSpawner

class PortalSeries:
    var portal_image : PackedScene
    var portal_color : Color
    var portal_summon : PackedScene
    var portal_summon_id : int

    var inputs = []
    var input_rate = 0
    var outputs = []
    var output_rate = 0

@export var PortalInputScene : PackedScene
@export var PortalOutputScene : PackedScene
@export var PortalImages : Array[PackedScene]
@export var PortalColors : Array[Color]
@export var PortalSummons : Array[PackedScene]

@onready var _unused_colors : Array[Color] = PortalColors.duplicate()
@onready var _unused_summons : Array[PackedScene] = PortalSummons.duplicate()


func get_new_portal_series():
    var p = PortalSeries.new()
    p.portal_image = PortalImages.pick_random()

    p.portal_color = _unused_colors.pick_random()
    _unused_colors.erase(p.portal_color)

    p.portal_summon = _unused_summons.pick_random()
    _unused_summons.erase(p.portal_summon)

    var o = p.portal_summon.instantiate()
    p.portal_summon_id = o.ObjectNum
    o.queue_free()

    return p

func can_get_series(): return _unused_colors.size() > 0 and _unused_summons.size() > 0

func spawn_input_portal(series : PortalSeries, grid_pos : Vector2i, spawn_rate=-1):
    var p = PortalInputScene.instantiate()
    p.SummonedObject = series.portal_summon
    p.set_summon_dir(randi() % 4 + 1)
    # Random between (2, 4, 8)
    p.set_summon_rate(2 ** (randi() % 3 + 1) if spawn_rate == -1 else spawn_rate)
    get_parent().add_child(p)

    p.position = GridController.to_world_pos(grid_pos)
    GridController.insert(grid_pos, p)

    var img = series.portal_image.instantiate()
    p.modulate = series.portal_color
    p.add_child(img)

    return p


func spawn_output_portal(series : PortalSeries, grid_pos : Vector2i, empty_rate=-1):
    var p = PortalOutputScene.instantiate()
    p.FilteredObject = series.portal_summon_id
    # Random between (1, 2, 4, 8)
    p.set_empty_rate(2 ** (randi() % 4) if empty_rate == -1 else empty_rate)

    get_parent().add_child(p)

    p.position = GridController.to_world_pos(grid_pos)
    GridController.insert(grid_pos, p)

    var img = series.portal_image.instantiate()
    p.modulate = series.portal_color
    p.add_child(img)

    return p

func get_portal_spawn_pos(tries=20):
    if tries <= 0: return null
    tries -= 1

    # Don't allow portals to be spawned on boundaries
    var size = GridController.MaxGrid - GridController.MinGrid - Vector2i(1, 1)
    var pos = Vector2i(randi() % size.x + GridController.MinGrid.x + 1, randi() % size.y + GridController.MinGrid.y + 1)

    var valid = true
    for x in range(-1, 2):
        for y in range(-1, 2):
            var p = pos + Vector2i(x, y)
            var c = GridController.pos_contents(p)
            
            # Portals can't spawn adjacent to portals
            if c != null and c.ObjType == Constants.ObjectType.Portal:
                valid = false
                break
            # Portals can't spawn on top of placed objects
            elif c != null and x == 0 and y == 0:
                valid = false
                break

        if not valid: break

    if not valid: return get_portal_spawn_pos(tries)

    return pos

