@tool
extends ItemList

const item_bg = preload( "res://Assets/ItemBG.tres" )

const food_names = ["apple", "baguette", "banana", "beet", "bread", "broccoli", "burger", "cabbage", "cake", "carrot", "cauliflower", "celery", "cheese", "cheeseburger", "cherries", "chocolate", "cookie", "cream", "croissant", "cupcake", "donut", "eggplant", "fries", "grapes", "leek", "lemon", "milk", "muffin", "onion", "orange", "pear", "pie", "pineapple", "radish", "sandwich", "soda", "soup", "strawberry", "taco", "tomato", "waffle", "watermelon"]

const food_scale = [ 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250 ]

@onready var mode_2dx = $%Mode2DX
@onready var icons = $%Mode2DX/InventoryIcons

# Called when the node enters the scene tree for the first time.
func _ready():
	clear()
	var y = 32 + 4
	for food_name in food_names:
		add_item( food_name.to_pascal_case(), item_bg, false )
		#icons.add_icon( food_name, Vector2(32+4,y) )
		icons.add_icon( "apple", Vector2(32+4,y+16) )
		y += 64+4
