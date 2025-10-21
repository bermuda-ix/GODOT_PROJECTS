class_name inventory_ui extends Control

const inv_items: PackedScene = preload("res://Component/functions/PersistentData/inventory_resources/inv_items/inv_item.tscn")
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
	new_inv_item.set_amount(1)
	new_inv_item.set_item_texture(items_resources[item_res].texture)
	grid_container.add_child(new_inv_item)
	print("adding new inv item: ", new_inv_item.name)
	new_inv_item.update_ui()
	
func remove_inv_item(name : inv_item) -> void:
	print("remove new inv item: ", name)
	grid_container.remove_child(name)
	name.queue_free()
	
func update_inv_amount(name : inv_item, value : int) -> void:
	name.amount=value
