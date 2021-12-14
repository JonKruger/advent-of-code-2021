import pandas as pd
import numpy as np

def load_coordinates(file_name):
    df_coords = pd.read_csv(file_name, header=None, names=["x","y"])
    return df_coords

def load_folds(file_name):
    df_folds = pd.read_csv(file_name, header=None)
    return df_folds[0].str.split("=")

def build_grid(df_coords):
    df_grid = pd.DataFrame(columns=range(0, df_coords["x"].max() + 1), 
                           index=range(0, df_coords["y"].max() + 1))
    df_grid = df_grid.fillna(False)
    
    for row in df_coords.iterrows():
        df_grid.loc[row[1]["y"], row[1]["x"]] = True
    
    return df_grid

def fold_y(df_grid, y):
    df_top = df_grid.loc[range(0, y)]
    df_bottom = df_grid.loc[reversed(range(y + 1, df_grid.index.max() + 1))]
    df_bottom.index = list(range(df_top.index.max() - df_bottom.shape[0] + 1, df_top.index.max() + 1))
    df_new = df_top.astype(int).add(df_bottom.astype(int), fill_value=0).astype(bool)
    df_new.index = range(0, df_new.shape[0])
    return df_new

def fold_x(df_grid, x):
    df_left = df_grid[range(0, x)]
    df_right = df_grid[reversed(range(x + 1, df_grid.columns.max() + 1))]
    df_right.columns = list(range(df_left.columns.max() - df_right.shape[1] + 1, df_left.columns.max() + 1))
    df_new = df_left.astype(int).add(df_right.astype(int), fill_value=0).astype(bool)
    df_new.index = range(0, df_new.shape[0])
    return df_new

def fold(df_grid, direction, index):
    if direction == "fold along x":
        return fold_x(df_grid, index)
    elif direction == "fold along y":
        return fold_y(df_grid, index)
    raise Exception()

def process_folds(df_grid, folds, count):
    for i in range(0, count):
        df_grid = fold(df_grid, folds[i][0], int(folds[i][1]))
    return df_grid

def dot_count(df_grid):
    return df_grid.apply(pd.value_counts).loc[True].sum()

def print_grid(df_grid):
    df_grid.replace(True, "#").replace(False, ".").apply(lambda row: print("".join(row.values)), axis=1)

# test one fold
df_coords = load_coordinates("test_coordinates.csv")
folds = load_folds("test_folds.csv")
df_grid = build_grid(df_coords)
df_grid = process_folds(df_grid, folds, 1)
dots = dot_count(df_grid)
print_grid(df_grid)
if dots != 17:
    raise Exception(dots)
else:
    print("pass")

# test 2 folds
df_coords = load_coordinates("test_coordinates.csv")
folds = load_folds("test_folds.csv")
df_grid = build_grid(df_coords)
df_grid = process_folds(df_grid, folds, 2)
dots = dot_count(df_grid)
print_grid(df_grid)
if dots != 16:
    raise Exception(dots)
else:
    print("pass")


# the real thing
df_coords = load_coordinates("coordinates.csv")
folds = load_folds("folds.csv")
df_grid = build_grid(df_coords)

# part 1
df_grid = process_folds(df_grid, folds, 1)
print(dot_count(df_grid))

# part 2
df_grid = process_folds(df_grid, folds, folds.shape[0])
print_grid(df_grid)
