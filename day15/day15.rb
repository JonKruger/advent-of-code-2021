class Node
  attr_reader :risk_level, :neighbors
  attr_accessor :ending_point, :row, :column, :ending_row, :ending_column

  def initialize(risk_level)
    raise unless !risk_level.nil? && risk_level.is_a?(Integer)
    @risk_level = risk_level
    @ending_point = false
    @neighbors = []
  end

  def distance_from_end
    @distance_from_end ||= (ending_row - row) + (ending_column - column)
  end

  def neighbors_towards_end
    @neighbords_towards_end ||= neighbors.select { |n| n.row > row || n.column > column }
  end

  def avg_area_risk_level
    @avg_area_risk_level ||=
      begin
        values = neighbors_towards_end.map { |n| [n.risk_level] + n.neighbors_towards_end.map(&:risk_level) }.flatten
        values.empty? ? 0 : values.sum.to_f / values.size
      end
  end
end

class Path
  def initialize(nodes)
    @nodes = nodes.freeze
  end

  def total_risk
    @total_risk ||= nodes.size > 1 ? nodes[1..].map(&:risk_level).sum : 0
  end

  def next_step_paths
    if available_connections.any?
      available_connections.map do |c|
        new_route = (@nodes + [c]).flatten
        Path.new(new_route)
      end.flatten
    else
      [self]
    end
  end

  def available_connections
    @available_connections ||=
      begin
        # if we're at the end, we're done
        return [] if completed?

        all_unvisited_nodes = current_node.neighbors - @nodes

        # always pick the ending point if it's there
        if (all_unvisited_nodes.any? { |node| node.ending_point })
          all_unvisited_nodes.select { |node| node.ending_point }
        else # take the least risky next step
          all_unvisited_nodes
        end
      end
  end

  def nodes
    @nodes.dup.freeze
  end

  def current_node
    @current_node ||= @nodes.last
  end

  def stuck?
    available_connections.empty? && !completed?
  end

  def completed?
    current_node.ending_point
  end

  def projected_future_risk_level
    @projected_future_risk_level ||= (current_node.avg_area_risk_level * 2) + (current_node.distance_from_end * 5)
  end

  def pruning_score
    @pruning_score ||=
      begin
        total_risk + projected_future_risk_level
      end
  end
end

class PathNavigator
  attr_reader :paths

  def initialize(paths)
    @paths = paths
  end

  # Create a baseline line that goes straight to the end so that we can prune paths as
  # they exceed this value.
  def create_straightest_path(starting_node)
    next_direction = "right"
    path_nodes = [starting_node]
    current_node = starting_node
    while (current_node) do
      if next_direction == "right"
        next_node = current_node.neighbors.select { |n| n.row > current_node.row && n.column == current_node.column}.first ||
          current_node.neighbors.select { |n| n.row == current_node.row && n.column > current_node.column}.first
      else
        next_node = current_node.neighbors.select { |n| n.row == current_node.row && n.column > current_node.column}.first ||
          current_node.neighbors.select { |n| n.row > current_node.row && n.column == current_node.column}.first
      end

      path_nodes << next_node if next_node
      current_node = next_node
      next_direction = next_direction == "right" ? "down" : "right"
    end
    paths << Path.new(path_nodes)
  end

  def step
    @paths = paths.map { |path| path.next_step_paths }.flatten
    prune
    nil
  end

  def prune
    # prune paths that can't go anywhere
    @paths = @paths.select { |path| !path.stuck? }

    # prune completed paths that aren't the best, along with incomplete paths that
    # are already worse than the best completed path
    best_completed_path = @paths.select { |path| path.completed? }.sort_by(&:total_risk).first
    if best_completed_path
      @paths = @paths.select { |path| !path.completed? && path.total_risk < best_completed_path.total_risk } + [best_completed_path].compact
    end

    # for each node, find the path ending at that node with the lowest risk prune the rest
    @paths = @paths.group_by(&:current_node).map { |_, paths| paths.sort_by(&:total_risk).first }

    pruning_limit = 100
    if @paths.size > pruning_limit
      @paths = @paths.sort_by(&:pruning_score)[0...pruning_limit] + [best_completed_path].compact
    end
  end

  def continue?
    !paths.all?(&:completed?)
  end

  def incomplete_paths
    paths.select { |path| path.completed? == false }
  end

  def completed_paths
    paths.select(&:completed?)
  end

  def best_completed_path
    completed_paths.sort_by(&:total_risk).first
  end

  def percent_completed
    completed_paths.size.to_f / paths.size.to_f
  end

  def total_risk
    best_completed_path&.total_risk
  end
end

def build_nodes(input)
  rows = input.split("\n").compact.map { |row| row.chars.compact.map { |value| Node.new(value.to_i) } }
  rows.last.last.ending_point = true
  num_rows = rows.size
  num_cols = input.split("\n").compact[0].length

  (0...num_rows).each do |row|
    (0...num_cols).each do |col|
      this_node = rows[row][col]
      this_node.row = row
      this_node.column = col
      this_node.ending_row = num_rows
      this_node.ending_column = num_cols
      this_node.neighbors << rows[row][col-1] if col > 0
      this_node.neighbors << rows[row][col+1] if col < num_cols - 1
      this_node.neighbors << rows[row-1][col] if row > 0
      this_node.neighbors << rows[row+1][col] if row < num_rows - 1
    end
  end
  rows
end

def lowest_risk(input)
  start = Time.now

  grid = build_nodes(input)
  starting_path = Path.new([grid[0][0]])
  navigator = PathNavigator.new([starting_path])
  navigator.create_straightest_path(grid[0][0])

  step_count = 0
  max_steps = 2
  last_step_time = Time.now
  while (navigator.continue?) do
    navigator.step
    step_count += 1
    puts("step #{step_count} - #{navigator.paths.size} paths (#{Time.now - last_step_time} seconds) - #{navigator.percent_completed * 100}% complete")
    last_step_time = Time.now
  end

  puts("calculated lowest risk #{navigator.total_risk} in #{(Time.now - start)} seconds with #{step_count} steps")
  navigator.total_risk
end

test_input = <<-INPUT
116
158
213
INPUT

result = lowest_risk(test_input)
raise result.inspect if result != 7

test_input = <<-INPUT
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
INPUT
result = lowest_risk(test_input)
raise result.inspect if result != 40

input = File.read("input.txt")
puts("step 1 - #{lowest_risk(input)}")
