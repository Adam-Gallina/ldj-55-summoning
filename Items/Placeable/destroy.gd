extends GridObject

func summon_interact(summon : SummonObject):
    summon.queue_free()
