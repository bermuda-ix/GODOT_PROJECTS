class_name inventory_ui extends Control

@onready var inv_items: PackedScene = preload("res://Component/functions/PersistentData/inventory_resources/inv_items/inv_item.tscn")
@onready var grid_container: GridContainer = $GridContainer
@export var items_resources : Array[inventory_item]

func _ready() -> void:
	print(items_resources[0].name)
	Events.add_inventory.connect(add_inv_item)
	Events.remove_inventory.connect(remove_inv_item)
	Events.update_inventory.connect(update_inv_amount)

func add_inv_item(name : String) -> void:
	var new_inv_item = inv_items.instantiate()
	var item_res : int
	for i in items_resources.size():
		if items_resources[i].name == name:
			item_res=i
			break
		else:
			push_error("ITEM RESOURCE MISSING: Please check if item resource is in items_resources array in inventory_ui.gd")
	new_inv_item.name=name
	grid_container.add_child(new_inv_item)
	new_inv_item.set_amount(1)
	new_inv_item.set_item_texture(items_resources[item_res].texture)
	print("adding new inv item: ", new_inv_item.name)
	new_inv_item.update_ui()
	
func remove_inv_item(name : String) -> void:
	print("remove new inv item: ", name)
	var inv_remove : inv_item = grid_container.find_child(name)
	grid_container.remove_child(inv_remove)
	inv_remove.queue_free()
	
func update_inv_amount(name : String, value : int) -> void:
	var inv_update : inv_item = grid_container.find_child(name)
	print(inv_update.name, " is updating")
	inv_update.amount_text.text=str(value)
