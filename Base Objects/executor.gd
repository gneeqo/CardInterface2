class_name Executor extends Node
##base Executor class.

@export_enum("World Space","UI space") var globalList : int
##Should this executor restart when all its actions are finished?
@export var loops : bool = false

var auto_init : bool = true

@export var resettable : bool

var unpaused_this_frame : bool = false

var start_clone_paused : bool = true

var triggered = false

var spawned_by_clone = false
##List of actions which need to be put into an [ActionList].
var executable_actions : Array[Action]

##if true: actions will not execute.
##if false: actions will execute.
var paused:bool = true

##Path to this node's parent.
var parent_path : NodePath :
	get: 
		return get_parent().get_path()

##[ActionList] which holds executable_actions.
var executable_list:ActionList
var lists : Array[ActionList]
##an unmodified version of the initial executor.
var self_clone : Executor

var initialized = false


func initialize_by_parent():
	
	auto_init = false
	#if this is invalid, any nodes which affect a node will fail to verify.
	executable_list = ActionList.new()
	
	var executable_list_populated = false
	#get this node's children into a list.
	for child in get_children():
		if child is Action:
			executable_actions.push_back(child)
			executable_list_populated = true
		elif child is ActionList:
			if executable_list_populated:
				#get the actions into an [ActionList].
				for action in executable_actions:
					action.affected_node_path = parent_path
					executable_list.add_action(action)
				lists.push_back(executable_list)
				
				executable_list_populated = false
			#get the list into the list of lists.
			lists.push_back(child)
			
		else:
			print("A non-action is a child of Executor in script : " +str(get_script().get_path()))
			breakpoint
	
	if executable_list_populated:
		#get the actions into an [ActionList].
		for action in executable_actions:
			action.affected_node_path = parent_path
			executable_list.add_action(action)
		lists.push_back(executable_list)
	if loops or resettable:
		copy_executor()
	
	initialized = true
	

func initialize_by_clone():
	if loops or resettable:
		copy_executor()
	initialized = true

func reset_executor():
	get_parent().add_child(self_clone)
	self_clone.initialize_by_clone()
	for list in lists:
		list.destroy_list()
	pause()
	queue_free()
	

func _clone()->Executor:
	var new_executor:Executor = new()
	for list in lists:
		new_executor.lists.push_back(list._clone())

	new_executor.loops = loops
	new_executor.resettable = resettable
	new_executor.spawned_by_clone = true
	
	return new_executor
	
			

func copy_executor():
	self_clone = _clone()
			


#if unpaused, execute the action lists.
#if looping, restart the action lists.
func _process(dt:float):
	if auto_init and not initialized:
		initialize_by_parent()
	
	var globallyPaused = false
	if globalList == 0 :
		globallyPaused = GlobalExecutorList.WorldSpacePaused
	elif globalList == 1:
		globallyPaused = GlobalExecutorList.WorldSpacePaused
	
	if globallyPaused : pass
	
	if not paused:
		if initialized:
			var reset = true
			for list in lists:
				if loops:
					if list.actions.size() != 0:
						reset = false			
			
				list.update_list(dt)
			if reset and loops:
				reset_executor()
				reset = false
	
	if resettable and not unpaused_this_frame and triggered:
			self_clone.paused = false
			interrupt_executor()
	unpaused_this_frame = false

##Stop execution.
func pause():
	paused = true

##Start execution.
func unpause():
	unpaused_this_frame = true
	paused = false

##Toggle execution.
func toggle_pause():
	paused = !paused
	
	if not paused:
		unpaused_this_frame = true
	
#perhaps do more with this function later.
func interrupt_executor():
	reset_executor()
