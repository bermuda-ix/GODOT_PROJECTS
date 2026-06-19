@tool
class_name SaveNode extends Node

const SAVE_NODE_GROUP : String = "save_node"

@export var properties_to_save : Array[String] = []

var suggested_properties : Array[String] = []

func _ready() -> void:
	add_to_group(SAVE_NODE_GROUP)
	if Engine.is_editor_hint():
		_update_property_list()
	
func _update_property_list() -> void:
	var parent = get_parent()
	
	if not parent:
		return
		
	suggested_properties.clear()
	var all_props = parent.get_property_list()
	
	for prop in all_props:
		var prop_name = prop.name
		suggested_properties.append(prop_name)
		
	notify_property_list_changed()
	
func _validate_property(property: Dictionary) -> void:
	if property.name == "properties_to_save":
		var options = ",".join(suggested_properties)
		property.hint = PROPERTY_HINT_TYPE_STRING
		property.hint_string = "%d/%d:%s" % [TYPE_STRING, PROPERTY_HINT_ENUM, options]
	
func load_save_data() -> Dictionary:
	var parent = get_parent()
	var node_data := {}
	for prop in properties_to_save:
		if prop in parent:
			node_data[prop] = parent.get(prop)
			
	return node_data
	
func apply_save_data(node_data : Dictionary) -> void:
	var parent = get_parent()
	for prop in parent:
		if prop in parent:
			parent.set(prop, node_data[prop])
