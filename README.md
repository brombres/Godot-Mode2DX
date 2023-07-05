# Mode2DX
A Godot node that allows a 3D scene to use a standard 2D coordinate system

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
#   - For example, the above quad's .scale would be set to Vector3(100,-50,1).
# - Pairs well with the 3D Drawing Order Godot Engine modification:
#   https://github.com/brombres/Godot-3D-Drawing-Order
#
# ABOUT
# - Version 1.0 by Brom Bresenham
# - Tested on Godot 4.1-RC
