
class ListButton extends Button

  type: ''

  status: ($node) ->
  
  command: (param) ->


class OrderListButton extends ListButton
  type: 'ol'
  name: 'ol'
  title: '有序列表'
  icon: 'list-ol'
  htmlTag: 'ol'

class UnorderListButton extends ListButton
  type: 'ul'
  name: 'ul'
  title: '无序列表'
  icon: 'list-ul'
  htmlTag: 'ul'

Simditor.Toolbar.addButton(OrderListButton)
Simditor.Toolbar.addButton(UnorderListButton)

