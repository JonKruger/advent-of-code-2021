class Element
  attr_reader :value
  def initialize(value)
    raise TypeError unless value.is_a?(Integer)
    @value = value
  end
end

def to_element(item)
  item.is_a?(Integer) ? Element.new(item) : item.map { |sub_item| to_element(sub_item) }
end

def to_values(item)
  item.is_a?(Element) ? item.value : item.map { |sub_item| to_values(sub_item) }
end

def explodes?(item, depth)
  item.is_a?(Array) && depth >= 4
end

def reduce(array, depth = 0)
  element_array = to_element(array)
  reduced = reduce_level(element_array, depth, element_array.flatten)
  to_values(reduced)
end

def reduce_level(element_array, depth, flattened_array)
  element_array.each_with_index do |item, i|
    if explodes?(item, depth + 1)
      # puts("boom", item.inspect, "x", flattened_array.inspect)
      left_item = flattened_array.index(item[0]) > 0 ? flattened_array[flattened_array.index(item[0]) - 1] : nil
      right_item = flattened_array.index(item[1]) < flattened_array.size - 1 ? flattened_array[flattened_array.index(item[1]) + 1] : nil
      element_array = [
        left_item ? Element.new(item[0].value + left_item.value) : Element.new(0),
        right_item ? Element.new(item[1].value + right_item.value) : Element.new(0)
      ]
    elsif item.is_a?(Array)
      element_array[i] = reduce_level(item, depth + 1, flattened_array)
    end
  end
  element_array
end


# 1st item explodes
result = reduce([[1,2],7], 3)
raise result.inspect unless result == [0,9]

# 2nd item explodes
result = reduce([7,[1,2]], 3)
raise result.inspect unless result == [8,0]


result = reduce([[[[[9,8],1],2],3],4])
raise result.inspect unless result == [[[[0,9],2],3],4]

result = reduce([7,[6,[5,[4,[3,2]]]]])
raise result.inspect unless result == [7,[6,[5,[7,0]]]]

result = reduce([[6,[5,[4,[3,2]]]],1])
raise result.inspect unless result == [[6,[5,[7,0]]],3]