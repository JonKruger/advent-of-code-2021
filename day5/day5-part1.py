import pandas as pd
import numpy as np

def load_data():
    df_input = pd.read_csv("adjusted_input.csv")
    
    # only horizontal or vertical lines
    df_input = df_input[(df_input["x1"] == df_input["x2"]) | (df_input["y1"] == df_input["y2"])]
    return df_input

def process_horizontal_lines(df_input, maxX, maxY):
    df_horizontal = df_input[df_input["y1"] == df_input["y2"]]
    h_chart = pd.DataFrame(index=range(0, maxY + 1), columns=range(0, maxX + 1)).fillna(0)
    
    for x1, x2, y in df_horizontal[["x1", "x2", "y1"]].values:
        # make sure x1 < x2
        x_values = [x1, x2]
        x1 = np.min(x_values)
        x2 = np.max(x_values)

        # add 1 to the left end of the line, subtract 1 from the column after the right
        # of the end of the line, then we'll cumsum() the rows to fill in the line            
        h_chart.loc[y, x1] = h_chart.loc[y, x1] + 1
        if (x2 + 1) in h_chart.columns:
            h_chart.loc[y, x2 + 1] = h_chart.loc[y, x2 + 1] - 1

    return h_chart.cumsum(axis=1)

def process_vertical_lines(df_input, maxX, maxY):
    df_vertical = df_input[df_input["x1"] == df_input["x2"]]
    v_chart = pd.DataFrame(index=range(0, maxY + 1), columns=range(0, maxX + 1)).fillna(0)
    
    for y1, y2, x in df_vertical[["y1", "y2", "x1"]].values:
        # make sure y1 < y2
        y_values = [y1, y2]
        y1 = np.min(y_values)
        y2 = np.max(y_values)

        # add 1 to the top end of the line, subtract 1 from the row after the bottom
        # of the end of the line, then we'll cumsum() the columns to fill in the line
        v_chart.loc[y1, x] = v_chart.loc[y1, x] + 1
        if (y2 + 1) in v_chart.index:
            v_chart.loc[y2 + 1, x] = v_chart.loc[y2 + 1, x] - 1

    return v_chart.cumsum()

def process(df_input):
    maxX = np.max([df_input["x1"].max(), df_input["x2"].max()])
    maxY = np.max([df_input["y1"].max(), df_input["y2"].max()])
    h_chart = process_horizontal_lines(df_input, maxX, maxY)
    v_chart = process_vertical_lines(df_input, maxX, maxY)
    return h_chart.add(v_chart)

def num_overlapping_points(df_result):
    return df_result[df_result >= 2].count().sum()

def compare(test_data, expected_output):
    maxX = len(expected_output[0])
    maxY = len(expected_output)
    df_input = pd.DataFrame(test_data, columns=["x1","y1","x2","y2"])
    df_expected_output = pd.DataFrame(expected_output, index=range(0,maxY), columns=range(0,maxX))
    result = process(df_input)
    if result.equals(df_expected_output) == False:
        print("actual:")
        print(result)
        print("expected:")
        print(df_expected_output)
        raise Exception()
    else:
        print("pass")

def test_simple_horizontal_example():
    test_data =         [[1,1,2,1]]
    expected_output =         [[0,0,0],
        [0,1,1]]
    compare(test_data, expected_output)
test_simple_horizontal_example()

def test_reversed_horizontal_example():
    test_data =         [[2,1,1,1]]
    expected_output =         [[0,0,0],
        [0,1,1]]
    compare(test_data, expected_output)
test_reversed_horizontal_example()

def test_simple_vertical_example():
    test_data =         [[1,1,1,2]]
    expected_output =         [[0,0],
        [0,1],
        [0,1]]
    compare(test_data, expected_output)
test_simple_vertical_example()

def test_reversed_vertical_example():
    test_data =         [[1,2,1,1]]
    expected_output =         [[0,0],
        [0,1],
        [0,1]]
    compare(test_data, expected_output)
test_reversed_vertical_example()

def test_overlapping_horizontal_example():
    test_data =         [[1,1,2,1],
        [0,1,1,1]]
    expected_output =         [[0,0,0],
        [1,2,1]]
    compare(test_data, expected_output)
test_overlapping_horizontal_example()

def test_overlapping_vertical_example():
    test_data =         [[1,1,1,2],
        [1,0,1,1]]
    expected_output =         [[0,1],
        [0,2],
        [0,1]]
    compare(test_data, expected_output)
test_overlapping_vertical_example()

def test_overlapping_horizontal_and_vertical_example():
    test_data =         [[1,1,1,2],
        [1,1,2,1]]
    expected_output =         [[0,0,0],
        [0,2,1],
        [0,1,0]]
    compare(test_data, expected_output)
test_overlapping_horizontal_and_vertical_example()

def test_num_overlapping_points():
    result_data = [[0,1,2],[3,1,0]]
    df_result = pd.DataFrame(result_data, index=range(0,2), columns=range(0,3))
    actual = num_overlapping_points(df_result)
    if actual != 2:
        print("actual")
        print(actual)
        raise Exception()
    else:
        print("pass")
test_num_overlapping_points()

def test_example_from_requirements():
    test_data =         [[0,9,5,9],
         [8,0,0,8],
         [9,4,3,4],
         [2,2,2,1],
         [7,0,7,4],
         [6,4,2,0],
         [0,9,2,9],
         [3,4,1,4],
         [0,0,8,8],
         [5,5,8,2]
        ]
    expected_output =         [[0,0,0,0,0,0,0,1,0,0],
        [0,0,1,0,0,0,0,1,0,0],
        [0,0,1,0,0,0,0,1,0,0],
        [0,0,0,0,0,0,0,1,0,0],
        [0,1,1,2,1,1,1,2,1,1],
        [0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0],
        [2,2,2,1,1,1,0,0,0,0]]
    compare(test_data, expected_output)
    
test_example_from_requirements()

# do it
df_input = load_data()
result = process(df_input)
print(num_overlapping_points(result))

