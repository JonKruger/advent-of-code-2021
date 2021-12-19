class Node
  attr_accessor :value, :parent, :children

  def initialize(value = nil, parent = nil)
    @value = value
    @parent = parent
    @children = []
  end

  def children=(value)
    raise TypeError unless value.is_a?(Array)
    raise value "cannot have both value and children" if self.value
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

  def magnitude
    if children.any?
      ((3 * children[0].magnitude) + (2 * children[1].magnitude))
    else
      value
    end
  end

  def validate
    if parent
      raise "parent's children doesn't include this node (#{to_array.inspect})" unless parent.children.include?(self)
    end
    if children.any?
      children.each do |child|
        raise "child doesn't have parent set (parent = #{to_array.inspect}, child = #{child.to_array.inspect})" unless child.parent == self
        child.validate
      end
    end
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

def magnitude(array)
  root_node = to_root_node(array)
  root_node.magnitude
end

def add(arrays)
  current_root_node = nil
  arrays.each do |array|
    this_root_node = to_root_node(array)
    if current_root_node.nil?
      current_root_node = this_root_node
    else
      new_root = Node.new
      current_root_node.parent = new_root
      this_root_node.parent = new_root
      new_root.children = [current_root_node, this_root_node]
      reduce(new_root)
      current_root_node = new_root
    end
  end
  current_root_node.to_array
end

def reduce(root_node)
  while (explode(root_node) || split(root_node)) do
    # root_node.validate
  end
  root_node.to_array
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
    Node.new((splittable.value.to_f / 2).floor, split_node),
    Node.new((splittable.value.to_f / 2).ceil, split_node)
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
root_node = to_root_node([[[[[1,2],7]]]])
result = reduce(root_node)
raise result.inspect unless result == [[[[0,9]]]]

# 2nd item explodes
root_node = to_root_node([[[[7,[1,2]]]]])
result = reduce(root_node)
raise result.inspect unless result == [[[[8,0]]]]

# exploding test cases
root_node = to_root_node([[[[[9,8],1],2],3],4])
result = reduce(root_node)
raise result.inspect unless result == [[[[0,9],2],3],4]

root_node = to_root_node([7,[6,[5,[4,[3,2]]]]])
result = reduce(root_node)
raise result.inspect unless result == [7,[6,[5,[7,0]]]]

root_node = to_root_node([[6,[5,[4,[3,2]]]],1])
result = reduce(root_node)
raise result.inspect unless result == [[6,[5,[7,0]]],3]

root_node = to_root_node([[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]])
result = reduce(root_node)
raise result.inspect unless result == [[3,[2,[8,0]]],[9,[5,[7,0]]]]

# splitting
root_node = to_root_node([15,1])
result = reduce(root_node)
raise result.inspect unless result == [[7,8],1]

# exploding and splitting together
root_node = to_root_node([[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]])
result = reduce(root_node)
raise result.inspect unless result == [[[[0,7],4],[[7,8],[6,0]]],[8,1]]

# adding
array1 = [[[[4,3],4],4],[7,[[8,4],9]]]
array2 = [1,1]
result = add([array1, array2])
raise result.inspect unless result == [[[[0,7],4],[[7,8],[6,0]]],[8,1]]

arrays = [
  [1,1],
  [2,2],
  [3,3],
  [4,4],
  [5,5],
  [6,6]
]
result = add(arrays)
raise result.inspect unless result == [[[[5,0],[7,4]],[5,5]],[6,6]]

arrays = [
  [[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]],
  [7,[[[3,7],[4,3]],[[6,3],[8,8]]]],
  [[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]],
  [[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]],
  [7,[5,[[3,8],[1,4]]]],
  [[2,[2,2]],[8,[8,1]]],
  [2,9],
  [1,[[[9,3],9],[[9,0],[0,7]]]],
  [[[5,[7,4]],7],1],
  [[[[4,2],2],6],[8,7]]
]
result = add(arrays)
raise result.inspect unless result == [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]

# magnitude
result = magnitude([[9,1],[1,9]])
raise result.inspect unless result == 129

result = magnitude([[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]])
raise result.inspect unless result == 3488

# run the real thing
arrays = [
  [[[[2,2],7],[[9,2],[5,2]]],[4,[[8,9],9]]],
  [[8,8],[5,[[2,9],1]]],
  [0,[3,[[9,2],[3,1]]]],
  [9,[[4,5],[5,[3,2]]]],
  [[0,[4,3]],[2,[[1,4],[3,0]]]],
  [[[9,[0,2]],[[2,6],9]],2],
  [1,[[[6,0],[2,6]],[[7,5],[5,6]]]],
  [[[1,[6,6]],[6,[5,2]]],[[[5,6],4],9]],
  [6,[[7,[1,4]],4]],
  [[[[7,6],[0,5]],[[5,4],0]],[[3,[2,3]],[[0,2],[6,4]]]],
  [[[3,4],7],[[[8,1],7],[3,[1,8]]]],
  [[[[6,5],0],[[5,2],6]],[[1,3],[0,[5,2]]]],
  [[[1,2],3],[[0,[3,7]],[4,[5,2]]]],
  [[[[4,4],3],2],[2,[6,3]]],
  [[[4,5],[[6,4],[8,5]]],[[[5,1],3],[8,3]]],
  [[6,[[9,0],6]],[3,[[3,3],3]]],
  [[8,[5,[1,7]]],[[4,5],[1,2]]],
  [[[[9,1],0],[[1,6],9]],[[8,[7,4]],9]],
  [[[3,1],[3,[5,5]]],[[[8,4],[2,9]],[6,[0,1]]]],
  [[7,4],[[6,3],[[8,3],[2,3]]]],
  [[[2,[5,6]],[[7,9],[8,7]]],[[3,5],[[1,7],[9,8]]]],
  [[[[2,8],1],[[1,9],[7,6]]],6],
  [[[[1,9],[5,5]],[7,8]],[[3,9],[2,[5,1]]]],
  [[4,[[6,7],6]],[1,[6,[6,5]]]],
  [[[[0,3],[2,7]],[7,1]],[[4,3],[[1,0],6]]],
  [[[[0,8],7],[[5,4],[8,6]]],[[1,[6,5]],5]],
  [[6,[[0,3],5]],[[9,[9,8]],0]],
  [[0,1],9],
  [[[[3,0],4],4],4],
  [[[0,8],[[1,7],1]],[[9,1],[4,[2,4]]]],
  [[5,[[6,1],2]],[[4,[5,9]],[[8,6],6]]],
  [[4,9],[[5,0],[[4,4],3]]],
  [[[[7,7],3],[3,[0,0]]],[1,[[0,8],[9,9]]]],
  [[[1,6],[9,1]],4],
  [[4,4],[[[0,0],9],[[2,0],[8,7]]]],
  [[7,[[6,8],9]],[[2,[7,6]],[6,[8,1]]]],
  [[[[7,9],[6,9]],[7,[2,5]]],[[[4,8],[3,7]],8]],
  [[[8,7],[[9,8],[3,6]]],[[[2,1],[4,7]],[[3,9],5]]],
  [[0,[[9,8],[5,3]]],[[9,6],[1,6]]],
  [9,[[[7,4],[9,9]],5]],
  [[9,[[6,7],[2,6]]],[[[2,8],[1,9]],[[4,1],[6,2]]]],
  [[1,[9,5]],[0,[[1,8],0]]],
  [[3,[7,6]],[8,[[3,2],[3,0]]]],
  [[4,6],[6,3]],
  [[[1,5],[[7,8],[6,4]]],[[3,[5,4]],[[9,8],1]]],
  [[[[8,5],5],[[7,9],8]],[[5,2],[8,6]]],
  [[[[3,4],9],[2,8]],[1,[9,8]]],
  [[[6,9],8],[[7,9],[6,[8,5]]]],
  [[[[7,4],9],1],7],
  [[[[0,5],[3,4]],[9,[9,7]]],[[1,6],5]],
  [6,[[[9,9],6],[[5,6],7]]],
  [[[1,4],[[4,6],[9,4]]],[[[0,3],2],[[1,9],6]]],
  [[8,[1,8]],[1,[5,[2,0]]]],
  [[[4,5],[[6,6],1]],[[4,0],[[9,9],[3,6]]]],
  [[9,[[0,0],[5,3]]],[[5,1],7]],
  [[[9,4],[[5,1],[2,7]]],[6,[6,1]]],
  [[8,5],[[[0,2],[2,6]],[3,[5,0]]]],
  [[[[4,8],[3,6]],[3,[3,1]]],[0,[6,3]]],
  [[[5,[9,6]],[3,[1,7]]],[[1,[9,2]],[6,5]]],
  [[[[5,2],[9,4]],[[6,5],7]],[[4,8],[[7,1],2]]],
  [[[5,[1,5]],5],[[[5,1],[0,9]],6]],
  [[4,[3,[9,9]]],[[[7,1],[6,5]],2]],
  [8,[[7,6],[8,7]]],
  [[[[4,2],5],[3,2]],[[2,7],[[7,2],[9,2]]]],
  [[[8,1],1],[5,[[0,9],[5,9]]]],
  [[[[2,2],[4,0]],2],[[9,[5,4]],[[2,9],[8,6]]]],
  [[[[6,8],0],[4,[1,5]]],[6,[[8,0],[6,6]]]],
  [[[3,0],2],5],
  [[[2,6],[5,[9,9]]],2],
  [[[[4,8],7],[0,0]],[[8,6],[[9,6],9]]],
  [[[1,4],0],[[[8,8],[9,3]],5]],
  [[[7,[8,8]],[[0,9],3]],7],
  [[[[3,1],[9,9]],[[7,9],7]],[[6,5],[[4,7],5]]],
  [[[1,3],2],[8,0]],
  [[8,[[5,0],[4,4]]],2],
  [[3,4],[[[4,8],4],[[3,4],8]]],
  [[4,[5,1]],[[8,[8,2]],[[3,5],[6,4]]]],
  [[[[7,6],5],[9,[7,3]]],[[4,[6,4]],[[6,1],9]]],
  [[0,[3,1]],[[4,[5,7]],6]],
  [[2,[[7,2],[4,5]]],1],
  [[[0,2],[3,[2,8]]],[[0,[0,6]],[1,[7,7]]]],
  [[1,[0,[7,0]]],[[[1,2],[1,9]],[4,[1,4]]]],
  [[[5,[7,4]],[[5,9],[7,0]]],[[[7,9],3],[[5,5],1]]],
  [[[[7,9],[3,0]],3],[8,8]],
  [[[[6,7],4],[[0,3],3]],[[2,[5,3]],8]],
  [[0,5],[3,[[6,6],[5,2]]]],
  [9,[[2,[8,7]],[6,[2,6]]]],
  [7,[[[1,9],[2,9]],[[1,0],5]]],
  [[5,0],[8,[2,2]]],
  [[3,[2,[8,0]]],3],
  [[[0,2],[6,[4,5]]],[3,[9,[0,4]]]],
  [[[6,7],7],[[8,[4,5]],[4,[1,7]]]],
  [[[[2,7],[9,6]],[5,0]],3],
  [[[[3,2],5],[8,3]],[[4,1],[[8,8],[6,4]]]],
  [[[2,[5,3]],[1,4]],[[[3,9],9],[[7,8],[5,7]]]],
  [5,[[[8,2],[0,4]],[[5,3],0]]],
  [[[3,4],3],[3,[[3,8],[2,1]]]],
  [5,[[[3,8],[5,2]],2]],
  [[[[3,8],6],[8,9]],[[3,[7,5]],[[4,4],2]]],
  [[[2,[3,9]],[[4,5],[7,9]]],5]
]
result = add(arrays)
puts("part 1 - #{magnitude(result)}")

max_magnitude = arrays.product(arrays).map do |array1, array2|
  magnitude(add([array1, array2]))
end.max

puts("part2 - #{max_magnitude}")