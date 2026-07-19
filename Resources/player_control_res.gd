class_name PlayerControls
extends Resource
enum DeviceType { KB, JOYPAD }
var player_index := 0
@export var deviceid := "kb1"
@export var joypadid := 0
@export var dtype : DeviceType = DeviceType.KB
@export var move_left := "kb1_move_left"
@export var move_right := "kb1_move_right"
@export var move_up := "kb1_move_up"
@export var move_down := "kb1_move_down"
@export var action := "kb1_action"
@export var leave := "kb1_leave"
