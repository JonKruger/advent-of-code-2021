const range = (min, max) => {
    return Array.from({length: max - min + 1}, (v, k)=> k + min);
}

const sumTo = (value) => {
    return (value * (value + 1)) / 2;
}

const processInputPart1 = async (input) => {
    const min = Math.min(...input);
    const max = Math.max(...input);

    const promises = [];
    for (position of range(min, max)) {
        promise = new Promise((resolve) => {
            fuel_costs = input
                .map((current_location) => Math.abs(current_location - position))
            total_fuel_cost = fuel_costs.reduce((sum, value) => sum += value, 0)
            result = {position, total_fuel_cost}
            resolve(result)
        })
        promises.push(promise)
    } 
    const options = await Promise.all(promises)
        .catch((error) => console.log(error));

    const min_fuel_cost = Math.min(...options.map((option) => option.total_fuel_cost));
    return options.filter((option) => option.total_fuel_cost == min_fuel_cost)[0];
}

const processInputPart2 = async (input) => {
    const min = Math.min(...input);
    const max = Math.max(...input);

    const promises = [];
    for (position of range(min, max)) {
        promise = new Promise((resolve) => {
            fuel_costs = input
                .map((current_location) => sumTo(Math.abs(current_location - position)))
            total_fuel_cost = fuel_costs.reduce((sum, value) => sum += value, 0)
            result = {position, total_fuel_cost}
            resolve(result)
        })
        promises.push(promise)
    } 
    const options = await Promise.all(promises)
        .catch((error) => console.log(error));

    const min_fuel_cost = Math.min(...options.map((option) => option.total_fuel_cost));
    return options.filter((option) => option.total_fuel_cost == min_fuel_cost)[0];
}

const compare = (obj1, obj2) => {
    return JSON.stringify(obj1) == JSON.stringify(obj2);
}

const puzzle_input = [1101, 1, 29, 67, 1102, 0, 1, 65, 1008, 65, 35, 66, 1005, 66, 28, 1, 67, 65, 20, 4, 0, 1001, 65, 1, 65, 1106, 0, 8, 99, 35, 67, 101, 99, 105, 32, 110, 39, 101, 115, 116, 32, 112, 97, 115, 32, 117, 110, 101, 32, 105, 110, 116, 99, 111, 100, 101, 32, 112, 114, 111, 103, 114, 97, 109, 10, 807, 891, 601, 565, 31, 61, 126, 1220, 923, 21, 750, 38, 834, 1494, 1187, 235, 138, 344, 438, 1078, 1664, 936, 451, 86, 34, 292, 782, 923, 154, 1060, 286, 713, 1557, 1693, 95, 7, 263, 1100, 402, 472, 342, 384, 95, 968, 319, 193, 1130, 983, 100, 88, 1020, 720, 693, 790, 113, 30, 30, 759, 151, 1039, 111, 172, 46, 478, 341, 182, 229, 96, 750, 88, 254, 105, 599, 1074, 20, 366, 307, 286, 25, 467, 927, 1000, 898, 139, 757, 20, 13, 51, 284, 323, 271, 26, 93, 178, 354, 1016, 165, 39, 1243, 383, 89, 141, 52, 260, 831, 681, 189, 439, 8, 4, 1849, 272, 1904, 377, 422, 468, 193, 81, 204, 8, 1165, 919, 16, 404, 442, 1571, 124, 76, 534, 323, 43, 16, 1039, 68, 203, 177, 60, 963, 100, 34, 35, 433, 17, 14, 432, 60, 835, 789, 191, 248, 256, 68, 367, 326, 1271, 329, 23, 992, 156, 627, 365, 798, 154, 457, 71, 489, 3, 403, 1138, 23, 1085, 128, 124, 270, 65, 279, 564, 145, 612, 412, 700, 387, 598, 7, 125, 764, 1456, 1433, 1010, 874, 262, 3, 39, 3, 157, 280, 182, 1, 1534, 49, 237, 873, 585, 424, 870, 93, 406, 4, 343, 956, 207, 271, 727, 62, 376, 35, 49, 74, 1532, 1318, 11, 637, 398, 1508, 143, 200, 339, 331, 14, 447, 121, 886, 512, 0, 79, 246, 1292, 269, 71, 83, 126, 124, 120, 38, 430, 238, 311, 460, 549, 544, 1050, 421, 421, 67, 82, 25, 1730, 134, 923, 161, 417, 178, 1730, 81, 34, 921, 1283, 648, 149, 76, 390, 1311, 677, 182, 184, 1109, 576, 1079, 569, 136, 106, 35, 1205, 170, 216, 908, 523, 54, 80, 87, 1278, 1080, 885, 1028, 423, 310, 71, 183, 395, 1269, 268, 356, 628, 1173, 1026, 816, 715, 751, 231, 31, 86, 625, 1231, 310, 86, 226, 405, 111, 991, 261, 145, 487, 196, 183, 234, 346, 987, 268, 28, 299, 40, 313, 597, 387, 44, 648, 134, 78, 302, 1189, 898, 56, 957, 175, 193, 170, 186, 170, 7, 1789, 8, 632, 503, 587, 229, 72, 286, 522, 145, 653, 5, 29, 31, 486, 145, 258, 784, 513, 341, 331, 223, 387, 986, 374, 512, 1074, 80, 119, 369, 557, 57, 18, 66, 1113, 251, 151, 319, 138, 485, 623, 577, 398, 487, 281, 113, 864, 273, 30, 29, 1184, 194, 1531, 503, 147, 402, 1587, 525, 288, 1015, 921, 601, 53, 346, 972, 646, 151, 163, 61, 585, 242, 67, 258, 36, 586, 347, 322, 341, 251, 112, 1250, 70, 35, 36, 110, 392, 44, 60, 401, 34, 563, 374, 977, 252, 184, 384, 84, 912, 215, 1198, 176, 630, 708, 791, 1622, 343, 454, 576, 218, 1054, 118, 14, 10, 665, 551, 20, 259, 497, 289, 176, 72, 524, 4, 147, 1323, 596, 1512, 104, 278, 332, 283, 43, 804, 326, 258, 247, 776, 665, 435, 1683, 286, 516, 677, 287, 1227, 409, 411, 49, 425, 207, 78, 157, 487, 364, 727, 976, 347, 158, 292, 28, 139, 1040, 217, 256, 1385, 600, 95, 339, 32, 64, 53, 31, 394, 154, 281, 1334, 161, 1291, 1474, 13, 453, 1461, 25, 272, 594, 832, 473, 1117, 207, 1107, 595, 732, 1284, 77, 504, 154, 960, 191, 1416, 429, 587, 654, 457, 462, 457, 697, 45, 366, 960, 1486, 273, 747, 1366, 389, 453, 1278, 852, 221, 950, 537, 29, 109, 1052, 112, 331, 349, 790, 903, 215, 135, 1457, 63, 997, 8, 226, 1440, 587, 1044, 215, 152, 317, 336, 71, 52, 1612, 438, 218, 1818, 220, 186, 388, 654, 93, 450, 915, 1083, 145, 69, 296, 712, 185, 569, 849, 236, 1884, 117, 761, 136, 1260, 319, 1553, 751, 275, 181, 137, 144, 222, 322, 387, 38, 951, 510, 1051, 614, 1819, 436, 430, 1425, 8, 271, 387, 19, 205, 215, 21, 585, 462, 798, 27, 1512, 279, 831, 1113, 97, 371, 998, 677, 1488, 125, 5, 208, 417, 912, 1083, 276, 39, 919, 91, 29, 182, 1727, 650, 49, 727, 1389, 1389, 23, 725, 1109, 890, 594, 397, 246, 47, 520, 305, 282, 81, 157, 283, 1031, 65, 1355, 773, 480, 0, 162, 655, 46, 786, 677, 394, 506, 1581, 1011, 149, 248, 107, 212, 446, 163, 553, 1005, 1, 856, 32, 34, 682, 128, 328, 114, 7, 737, 188, 31, 1157, 590, 397, 159, 366, 449, 601, 225, 121, 320, 163, 849, 746, 122, 141, 443, 616, 72, 660, 244, 964, 718, 1628, 77, 129, 854, 206, 12, 458, 1130, 207, 26, 622, 502, 934, 979, 577, 611, 1187, 62, 981, 1692, 38, 11, 85, 1417, 1152, 1846, 520, 1001, 104, 595, 586, 945, 8, 624, 1043, 955, 262, 53, 453, 377, 234, 1363, 239, 1553, 760, 641, 615, 784, 633, 1289, 853, 1224, 834, 488, 521, 71, 510, 45, 41, 309, 50, 245, 423, 7, 520, 350, 137, 275, 429, 86, 144, 800, 172, 214, 679, 87, 321, 682, 1005, 278, 518, 330, 705, 613, 818, 1014, 469, 98, 581, 72, 1647, 165, 25, 510, 369, 1013, 598, 209, 6, 323, 530, 59, 41, 1266, 787, 1191, 149, 213, 8, 1490, 105, 288, 88, 607, 556, 50, 17, 76, 513, 717, 1236, 1532, 1455, 23, 77, 472, 573, 303, 0, 419, 573, 1217, 1, 144, 648, 95, 326, 999, 1359, 324, 172, 259, 516, 1178, 84, 1030, 73, 12, 867, 1477, 70, 147, 317, 999, 1377, 196, 342, 127, 787, 372, 687, 855, 5, 1663, 49, 552, 380, 95, 469, 132, 58, 397, 213, 194, 35, 1353, 216, 12, 497, 610, 571, 802, 392, 42, 490, 778, 6, 483, 1451];

(async () => {
    let result = await processInputPart1([16,1,2,0,4,2,7,1,2,14])
    if (!compare(result, {position: 2, total_fuel_cost: 37})) {
        console.log("error", result)
        throw("test failed")
    }
    else { console.log("pass") }

    result = await processInputPart1(puzzle_input);
    console.log("part1", result);

    result = await processInputPart2([16,1,2,0,4,2,7,1,2,14])
    if (!compare(result, {position: 5, total_fuel_cost: 168})) {
        console.log("error", result)
        throw("test failed")
    }
    else { console.log("pass") }

    result = await processInputPart2(puzzle_input);
    console.log("part2", result);
})()
