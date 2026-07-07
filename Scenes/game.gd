extends Node

@onready var viewport_1 = $VSplitContainer/SplitContainer/SVPC1/SVP
@onready var viewport_2 = $VSplitContainer/SplitContainer/SVPC2/SVP
@onready var viewport_3 = $VSplitContainer/SplitContainer2/SVPC3/SVP
@onready var viewport_4 = $VSplitContainer/SplitContainer2/SVPC4/SVP

func _ready() -> void:
	var world = viewport_1.find_world_2d()
	viewport_2.world_2d = world
	viewport_3.world_2d = world
	viewport_4.world_2d = world
