def explodes?(item, depth)
  item.is_a?(Array) && depth >= 4
end

def reduce(array, depth = 0)
  array.each_with_index do |item, i|
    if explodes?(item, depth + 1)
      left_item = i == 1 ? array[0] : nil
      right_item = i == 0 ? array[1] : nil
      raise if left_item && right_item
      # puts([i, array, left_item, right_item].inspect)

      array = [left_item + item[0], 0] if left_item
      array = [0, right_item + item[1]] if right_item
    elsif item.is_a?(Array)
      array[i] = reduce(item, depth + 1)
    end
  end
  array
end


# # 1st item explodes
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