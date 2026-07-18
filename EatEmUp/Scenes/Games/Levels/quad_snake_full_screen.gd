extends Node2D

@export var total_label : Label
@export var labels : Array[Label]

@onready var snakeone : Snake = $Snakes/Snake
@onready var snaketwo : Snake = $Snakes/Snake2
@onready var snakethree : Snake = $Snakes/Snake3
@onready var snakefour : Snake = $Snakes/Snake4

func _ready() -> void:
	var snakes : Array[Node] = $Snakes.get_children()
	for i in range(GlobalData.players.size()):
		var controls = GlobalData.players[i]
		var snake = snakes[i]
		if snake is Snake:
			snake.controls = controls
	for i in range(4):
		var snake = snakes[i]
		var label = labels[i]
		if snake is Snake:
			snake.label = label

func _physics_process(delta: float) -> void:
	var head1 = snakeone.Head() if is_instance_valid(snakeone) else GlobalData.safe_vector
	var head2 = snaketwo.Head() if is_instance_valid(snaketwo) else GlobalData.safe_vector
	var head3 = snakethree.Head() if is_instance_valid(snakethree) else GlobalData.safe_vector
	var head4 = snakefour.Head() if is_instance_valid(snakefour) else GlobalData.safe_vector
	var oneshits : Array[int] = []
	var twoshits : Array[int] = []
	var threeshits : Array[int] = []
	var fourshits : Array[int] = []
	var datasets : Array[Snake]
	
	if is_instance_valid(snakeone):
		oneshits.append(snakeone.check_for_hits_on_lost(head1))
		twoshits.append(snakeone.check_for_hits(head2))
		threeshits.append(snakeone.check_for_hits(head3))
		fourshits.append(snakeone.check_for_hits(head4))
		datasets.append(snakeone)
	if is_instance_valid(snaketwo):
		twoshits.append(snaketwo.check_for_hits_on_lost(head2))
		oneshits.append(snaketwo.check_for_hits(head1))
		threeshits.append(snaketwo.check_for_hits(head3))
		fourshits.append(snaketwo.check_for_hits(head4))
		datasets.append(snaketwo)
	if is_instance_valid(snakethree):
		threeshits.append(snakethree.check_for_hits_on_lost(head3))
		twoshits.append(snakethree.check_for_hits(head2))
		oneshits.append(snakethree.check_for_hits(head1))
		fourshits.append(snakethree.check_for_hits(head4))
		datasets.append(snakethree)
	if is_instance_valid(snakefour):
		fourshits.append(snakefour.check_for_hits_on_lost(head4))
		twoshits.append(snakefour.check_for_hits(head2))
		threeshits.append(snakefour.check_for_hits(head3))
		oneshits.append(snakefour.check_for_hits(head1))
		datasets.append(snakefour)
	
	$SnakesMesh.update_snake_mesh(datasets,delta)
	
	if is_instance_valid(snakeone):
		snakeone.addhits(oneshits)
	if is_instance_valid(snaketwo):
		snaketwo.addhits(twoshits)
	if is_instance_valid(snakethree):
		snakethree.addhits(threeshits)
	if is_instance_valid(snakefour):
		snakefour.addhits(fourshits)
	
	var total = snakeone.gettotal() + snaketwo.gettotal() + snakethree.gettotal() + snakefour.gettotal()
	total_label.text = str(total)
