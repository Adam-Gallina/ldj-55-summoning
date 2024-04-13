extends Node

enum ObjectType { None, Reroute, Splitter, Launch, Delay, Destroy, Teleport }

enum Direction { None, Up, Right, Down, Left }
func DirectionVector(dir : Direction):
    match dir:
        Direction.None: return Vector2()
        Direction.Up: return Vector2(0, -1)
        Direction.Right: return Vector2(1, 0)
        Direction.Down: return Vector2(0, 1)
        Direction.Left: return Vector2(-1, 0)

func DirectionCW(dir : Direction):
    match dir:
        Direction.None: return Direction.None
        Direction.Up: return Direction.Right
        Direction.Right: return Direction.Down
        Direction.Down: return Direction.Left
        Direction.Left: return Direction.Up

func DirectionCCW(dir : Direction):
    match dir:
        Direction.None: return Direction.None
        Direction.Up: return Direction.Left
        Direction.Right: return Direction.Up
        Direction.Down: return Direction.Right
        Direction.Left: return Direction.Down

func DirectionInverse(dir : Direction):
    match dir:
        Direction.None: return Direction.None
        Direction.Up: return Direction.Down
        Direction.Right: return Direction.Left
        Direction.Down: return Direction.Up
        Direction.Left: return Direction.Right