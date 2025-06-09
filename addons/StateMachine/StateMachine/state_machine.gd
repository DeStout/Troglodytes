extends Node
class_name StateMachine


@export var remote_state : State
@export var initial_state : State
@export var character : CharacterBody3D

var prev_state : State
var current_state : State
var states : Dictionary = {}


func _ready() -> void:
	if !character.is_multiplayer_authority():
		initial_state = remote_state
	if initial_state:
		current_state = initial_state
	elif get_child_count() > 0:
		current_state = get_child(0)
	else: return
	
	for state : Node in get_children():
		states[state.name.to_lower()] = state
		state.transition.connect(on_state_transitioned)
		state.character = character
	
	await character.ready
	current_state.enter()
	current_state.active = true


func _process(delta : float) -> void:
	if !character.is_multiplayer_authority():
		return
	current_state.update(delta)


func _physics_process(delta : float) -> void:
	if !character.is_multiplayer_authority():
		return
	current_state.physics_update(delta)


func on_state_transitioned(state : State, new_state_name : String) -> void:
	if !character.is_multiplayer_authority():
		return
	if state != current_state:
		printerr(character.name, ": Cannot change state from a non-active state (", \
						current_state.name, ", ", state.name, ", ", new_state_name, ")")
		breakpoint
		return
	
	if !current_state:
		printerr(character.name, ": Current state is null, cannot transition")
		return
	
	var new_state : State = states[new_state_name.to_lower()]
	if !new_state: 
		printerr(character.name, ": Transition state name does not match a \
												state's name (", new_state_name, ")")
	
	if current_state:
		current_state.exit()
		new_state.active = false
		current_state.active = false
	
	new_state.active = true
	prev_state = current_state
	current_state = new_state
	new_state.enter()
