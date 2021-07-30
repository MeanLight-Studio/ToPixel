tool
extends ReferenceRect

export (NodePath) var viewport_path

func _process(delta):
	_on_ReferenceRect_resized()

func _on_ReferenceRect_resized():
	var viewport : Viewport = get_node(viewport_path)
	var viewport_image := viewport.get_texture().get_data()
	viewport_image.flip_y()
	viewport_image = viewport_image.get_rect(get_rect())
	var texture := ImageTexture.new()
	texture.create_from_image(viewport_image)
	$TextureRect.texture = texture
