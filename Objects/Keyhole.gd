extends Area2D


func _on_area_entered(area:Area2D):
    print('a')
    var d:Room_Door = get_tree().get_first_node_in_group('door')
    d.start_door_open()
    queue_free(area)
