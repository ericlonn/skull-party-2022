extends Node

# Using enums for state names that way every script has the same interface
# while being more robust and less error prone than using strings
onready var states = {
	BaseState.State.Idle: $idle,
	BaseState.State.Run: $run,
	BaseState.State.Fall: $fall,
	BaseState.State.Jump: $jump,
	BaseState.State.Attack: $attack,
	BaseState.State.Stunned: $stunned,
	BaseState.State.Wall_Slide: $wall_slide,
	BaseState.State.Punch: $punch,
	BaseState.State.Fire_Weapon: $fire_weapon,
	BaseState.State.Dead: $dead,
	BaseState.State.Weapon: null
}

var current_state: BaseState

func change_state(new_state: int) -> void:
	if current_state:
		current_state.exit()
	
	
	current_state = states[new_state]
	current_state.enter()

# Initialize the state machine by giving each state a reference to the objects
# owned by the parent that they should be able to take control of
# and set a default state
func init(player: Player) -> void:
	for child in get_children():
		child.player = player

	# Initialize with a default state of idle
	change_state(BaseState.State.Idle)
	
# Pass through functions for the Player to call,
# handling state changes as needed
func process(delta: float) -> void:
	var new_state = current_state.process(delta)
	if new_state != BaseState.State.Null:
		change_state(new_state)
		
func physics_process(delta: float) -> void:
	var new_state = current_state.physics_process(delta)
	if new_state != BaseState.State.Null:
		change_state(new_state)

func input(event: InputEvent) -> void:
	var new_state = current_state.input(event)
	if new_state != BaseState.State.Null:
		change_state(new_state)
