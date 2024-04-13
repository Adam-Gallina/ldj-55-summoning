extends GridObject

func summon_interact(summon : SummonObject):
    summon.despawn()
    ScoreBoard.add_point()