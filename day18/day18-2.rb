class Node
  attr_accessor :value, :parent, :children

  def initialize(value = nil, parent = nil)
    @value = value
    @parent = parent
    @children = []
  end

  def children=(value)
    raise TypeError unless value.is_a?(Array)
    @children = value
  end

  def root_node
    parent&.root_node || self
  end

  def depth
    parent.nil? ? 0 : parent.depth + 1
  end

  def explodable
    if value.nil? && children.all? { |child| child.value && depth == 4 }
      [self]
    else
      children.map(&:explodable).flatten.compact
    end
  end

  def splittable
    if value && value >= 10
      [self]
    else
      children.map(&:splittable).flatten.compact
    end
  end

  def to_flat_array_of_nodes
    value ? [self] : children.map(&:to_flat_array_of_nodes).flatten
  end

  def to_array
    value ? value : children.map(&:to_array)
  end

  def search(value)
    return self if self.value == value
    return nil if self.value
    return children.map { |child| child.search(value) }.compact.first
  end

  def left_neighbor
    node_array = root_node.to_flat_array_of_nodes
    this_node_index = node_array.index(children[0])
    this_node_index > 0 ? node_array[this_node_index - 1] : nil
  end

  def right_neighbor
    node_array = root_node.to_flat_array_of_nodes
    this_node_index = node_array.index(children[1])
    this_node_index < node_array.size - 1 ? node_array[this_node_index + 1] : nil
  end
end

def to_node(item, parent)
  if item.is_a?(Integer)
    node = Node.new
    node.value = item
    node.parent = parent
  else
    node = Node.new
    node.parent = parent
    node.children = item.map { |child| to_node(child, node) }
  end

  node
end

def to_root_node(array)
  root_node = Node.new
  root_node.children = array.map { |item| to_node(item, root_node) }
  root_node
end

def reduce(array)
  # puts("start #{array.inspect}")
  root_node = to_root_node(array)
  while (explode(root_node) || split(root_node)) do
    # puts(root_node.to_array.inspect)
  end
  root_node.to_array
end


def to_elements(array, depth = 1)
  array.map { |item| item.is_a?(Integer) ? Element.new(item, depth) : to_elements(item, depth + 1) }
end

def explode(node)
  # If any pair is nested inside four pairs, the leftmost such pair explodes.
  explodable = node.explodable.first
  return false unless explodable

  # To explode a pair,
  #
  # the pair's left value is added to the first regular number to the left of the
  # exploding pair (if any),
  left_neighbor = explodable.left_neighbor
  left_neighbor.value += explodable.children[0].value if left_neighbor

  #
  # and the pair's right value is added to the first regular number to the
  # right of the exploding pair (if any). Exploding pairs will always consist of two regular numbers.
  right_neighbor = explodable.right_neighbor
  right_neighbor.value += explodable.children[1].value if right_neighbor

  # Then, the entire exploding pair is replaced with the regular number 0.
  explodable.parent.children = explodable.parent.children.map { |child| child == explodable ? Node.new(0, explodable.parent) : child }

  true
end

def split(node)
  # If any regular number is 10 or greater, the leftmost such regular number splits.
  splittable = node.splittable.first
  return false unless splittable

  # To split a regular number, replace it with a pair; the left element of the pair should be the regular number
  # divided by two and rounded down, while the right element of the pair should be the regular number divided by
  # two and rounded up. For example, 10 becomes [5,5], 11 becomes [5,6], 12 becomes [6,6], and so on.
  split_node = Node.new
  split_node.parent = splittable.parent
  split_node.children = [
    Node.new((splittable.value.to_f / 2).floor, splittable.parent),
    Node.new((splittable.value.to_f / 2).ceil, splittable.parent)
  ]
  splittable.parent.children = splittable.parent.children.map { |child| child == splittable ? split_node : child }

  true
end

# Node#to_array
node = to_root_node([[[[[1,2],7]]]])
raise unless node.to_array == [[[[[1,2],7]]]]

# Node#search
node = to_root_node([1,[2,3]])
raise unless node.search(1).value == 1
raise unless node.search(2).value == 2
raise unless node.search(3).value == 3

# Node#right_neighbor
node = to_root_node([[[[[1,2],7]]]])
explodable = node.search(2).parent
raise unless explodable.right_neighbor.value == 7
raise explodable.left_neighbor.to_array.inspect unless explodable.left_neighbor.nil?

node = to_root_node([[3,[2,[1,[7,8]]]],[6,[5,[4,[3,2]]]]])
explodable = node.search(8).parent
raise unless explodable.right_neighbor.value == 6
raise unless explodable.left_neighbor.value == 1

# Node#left_neighbor
node = to_root_node([[7,[[[1,2]]]]])
explodable = node.search(1).parent
raise unless explodable.left_neighbor.value == 7
raise unless explodable.right_neighbor.nil?

# Node#explodable_children
node = to_root_node([[[[[1,2],7]]]])
raise node.explodable[0].to_array.inspect unless node.explodable[0].to_array == [1,2]

# 1st item explodes
result = reduce([[[[[1,2],7]]]])
raise result.inspect unless result == [[[[0,9]]]]

# 2nd item explodes
result = reduce([[[[7,[1,2]]]]])
raise result.inspect unless result == [[[[8,0]]]]

# exploding test cases
result = reduce([[[[[9,8],1],2],3],4])
raise result.inspect unless result == [[[[0,9],2],3],4]

result = reduce([7,[6,[5,[4,[3,2]]]]])
raise result.inspect unless result == [7,[6,[5,[7,0]]]]

result = reduce([[6,[5,[4,[3,2]]]],1])
raise result.inspect unless result == [[6,[5,[7,0]]],3]

result = reduce([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])
raise result.inspect unless result == [[3,[2,[8,0]]],[9,[5,[7,0]]]]

# splitting
result = reduce([15,1])
raise result.inspect unless result == [[7,8],1]

# exploding and splitting together
result = reduce([[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]])
raise result.inspect unless result == [[[[0,7],4],[[7,8],[6,0]]],[8,1]]