extends Node

var players : Array[PlayerControls] = []
var nextscene : PackedScene = null
var tauthird = (2.0 * PI / 3.0)
var angles = PI/6
var halfpi = PI/2
var rotation_speed: float = 2.0
var rotation_range: float = 30.0 
var rstwicebypi = rotation_speed * 2.0 * PI
var min_limit = Vector2(250, 250)
var max_limit = Vector2(7430, 4070)
var centerofmap := Vector2(7680/2,4320/2)
var borderrect := Rect2(min_limit,max_limit)
var safe_vector = Vector2(-10000,-10000)
