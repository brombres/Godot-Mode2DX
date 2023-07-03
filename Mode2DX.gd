# USAGE
# - Create a 3D scene
# - Add a Camera3D (default configuration is fine)
# - Add this script as a top-level node.
#   - Adjust properties in the editor if desired ('nominal_z', etc.)
# - All subtrees of the Mode2DX node will use 2D coordinates.
#   - Mode2DX.display_size contains the current window size in pixels.
#   - (0,0) is top-left, bottom-right is Mode2DX.display_size - Vector2(1,1)
#   - Note that the Y axis is inverted, which requires the scale.y adjustment listed below.
#   - The Mode2DX node will automatically update appropriate transforms if the screen size changes.
# - The size * scale of each descendent node will be the pixel size it is drawn at.
#   - For example, a MeshInstance3D quad scaled to 100x50x1 will be 100x50 pixels onscreen.
# - Each descendent node's scale.y property should be negatated to draw at normal orientation.
#   - For example, the quad above's .scale would be set to Vector3(100,-50,1).
#
# ABOUT
# - Version 1.0 by Brom Bresenham
# - Tested on Godot 4.1-RC
extends Node3D

class_name Mode2DX

signal display_size_changed
	# Mode2DX receives the viewport's 'size_changed' signal and then updates the 2DX display settings
	# before emitting the 'display_size_changed' signal. Connecting to this signal ensures that
	# Mode2DX.display_size is up to date before the receiver performs any layout adjustments.

var display_size : Vector2
	# The current size of the viewport, in pixels. (0,0) is the top-left corner.

@export var nominal_z = 2000:
	# The depth at which 3D model size matches pixel size 1:1. The Mode2DX node is positioned at this
	# depth, so a child node with z=0 will have a 1:1 pixel size, a node with z=nominal_z*0.9 will be
	# closer to the camera, and a node with z=nominal_z*1.1 will be farther from the camera.
	#
	# Smaller nominal_z values exaggerate the effects of rotating into or moving along the Z axis,
	# while larger nominal_z values reduce the depth of the 3D effect.
	set(value): nominal_z=value; update_display_settings()

@export var z_far = 4000:
	# A good default for the far clipping plane. The near clipping plane is fixed at 1.
	set(value): z_far=value; update_display_settings()

@export var frustum_offset : Vector2:
	# Optional setting.
	set(value): frustum_offset=value; update_display_settings()

var current_camera  : Camera3D: get=_get_current_camera_3d
var _current_camera : Camera3D

func update_display_settings():
	# Called automatically on _ready(), when the viewport size changes, and from _process(). Can be
	# called manually e.g. to update 'display_size' immediately after the current camera is changed.
	var viewport = get_viewport()
	if not viewport: return

	var cur_size = viewport.get_visible_rect().size
	var prior_camera = _current_camera
	var cur_camera = current_camera
	if cur_size != display_size or cur_camera != prior_camera:
		display_size = cur_size

		var sz = display_size.y / (nominal_z + 1)
		cur_camera.set_frustum( sz, frustum_offset, 1, z_far )
		position = Vector3( -display_size.x/2, display_size.y/2, -nominal_z )
		scale = Vector3( 1, -1, 1 )
		print( str("[Mode2DX] ", cur_camera.name, ".set_frustum(",sz,",",frustum_offset,",1,",z_far,")") )
		print( str("[Mode2DX] ", name, ".position = ",position) )
		print( str("[Mode2DX] ", name, ".scale = ",scale) )

		display_size_changed.emit()

func _ready():
	get_viewport().connect( "size_changed", _on_viewport_size_changed )
	update_display_settings()

func _on_viewport_size_changed():
	update_display_settings()

func _process(_delta):
	update_display_settings()

func _get_current_camera_3d():
	if _current_camera and _current_camera.current:
		if _current_camera.get_viewport() == self.get_viewport():
			return _current_camera

	_current_camera = _find_camera_3d( $/root )
	if _current_camera: return _current_camera

	printerr( "[Mode2DX] ERROR: No current Camera3D exists. Add a Camera3D node to the scene." )
	return null

func _find_camera_3d( node:Node )->Camera3D:
	if node is Camera3D and node.current: return node
	for child in node.get_children():
		var result = _find_camera_3d( child )
		if result: return result
	return null
