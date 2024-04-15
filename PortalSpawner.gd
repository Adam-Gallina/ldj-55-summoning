extends Node2D
class_name PortalSpawner

class PortalSeries:
    var portal_image : PackedScene
    var portal_color : Color
    var portal_summon : PackedScene
    var portal_summon_id : int
    var portal_summon_img : Texture2D

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
    p.portal_summon_img = o.get_node('Sprite2D').texture
    o.queue_free()
    print(p.portal_summon_img)

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

    p.set_summon_img(series.portal_summon_img)

    return p


func spawn_output_portal(series : PortalSeries, grid_pos : Vector2i, empty_rate=-1):
    var p = PortalOutputScene.instantiate()
    p.FilteredObject = series.portal_summon_id
    # Random between (2, 3, 5, 9)
    p.set_empty_rate((2 ** (randi() % 4) + 1) if empty_rate == -1 else empty_rate)

    get_parent().add_child(p)

    p.position = GridController.to_world_pos(grid_pos)
    GridController.insert(grid_pos, p)

    var img = series.portal_image.instantiate()
    p.portal_warning.connect(img.get_node('Portal')._on_portal_warning)
    p.modulate = series.portal_color
    img.modulate = Color(.5,.5,.5)
    p.add_child(img)

    p.set_summon_img(series.portal_summon_img)
    
    return p

func get_portal_spawn_pos():#tries=20):
    #if tries <= 0:      
    #    printerr('Could not find valid pos')
    #    return null
    #tries -= 1

    var eligible = []

    # Don't allow portals to be spawned on boundaries
    for x in range(GridController.MinGrid.x+1, GridController.MaxGrid.x):
        for y in range(GridController.MinGrid.y+1, GridController.MaxGrid.y):
            if _is_valid_spawn_pos(Vector2i(x, y)):
                eligible.append(Vector2i(x, y))

    #var size = GridController.MaxGrid - GridController.MinGrid - Vector2i(1, 1)
    #var pos = Vector2i(randi() % size.x + GridController.MinGrid.x + 1, randi() % size.y + GridController.MinGrid.y + 1)

    if eligible.size() == 0:
        printerr('No eligible spawn positions')
        return null

    var pos = eligible.pick_random()
    return pos #if _is_valid_spawn_pos(pos) else get_portal_spawn_pos(tries)


func _is_valid_spawn_pos(grid_pos : Vector2i):
    for x in range(-1, 2):
        for y in range(-1, 2):
            var p = grid_pos + Vector2i(x, y)
            var c = GridController.pos_contents(p)
            
            # Portals can't spawn adjacent to portals
            if c != null and c.ObjType == Constants.ObjectType.Portal:
                return false
            # Portals can't spawn on top of placed objects
            elif c != null and x == 0 and y == 0:
                return false

    # Portals can't spawn in the early path of other portals
    for d in range(1,5):
        var dir = Constants.DirectionVector(d)
        var c = GridController.pos_contents(grid_pos + Vector2i(dir.x, dir.y) * 2)
        if c != null and c.ObjType == Constants.ObjectType.Portal:
            if c is InputPortal and c.get_summon_dir() == Constants.DirectionInverse(d):
                return false

    return true