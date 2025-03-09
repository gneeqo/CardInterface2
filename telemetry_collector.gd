class_name TelemetryCollector extends Node

#first timestamp, second information
# array contains a float at 0 and a string at 1
static var events_recorded : Array[Array]

static var telemetry_active : bool = false



static func add_event(event : String):
	#get current time
	var timestamp = Time.get_unix_time_from_system()
	#add event to list
	events_recorded.push_back([timestamp,event])

static func start_collecting():	
	events_recorded.clear()
	telemetry_active = true
	
static func finish_collecting():
	telemetry_active = false
	write_telemetry()
	
static func write_telemetry():
	print(events_recorded)
	
	pass
	
