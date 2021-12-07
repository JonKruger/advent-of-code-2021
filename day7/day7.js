range = (min, max) => {
    return Array.from({length: max - min + 1}, (v, k)=> k + min)
}

processInput = (input) => {
    min = Math.min(...input)
    max = Math.max(...input)

    options = []
    for (position of range(min, max)) {
        fuel_costs = input
            .map((current_location) => Math.abs(current_location - position))
        total_fuel_cost = fuel_costs.reduce((sum, value) => sum += value, 0)
        options.push({position, total_fuel_cost})
    } 

    min_fuel_cost = Math.min(...options.map((option) => option.total_fuel_cost))
    return options.filter((option) => option.total_fuel_cost == min_fuel_cost)[0]
}

compare = (obj1, obj2) => {
    return JSON.stringify(obj1) == JSON.stringify(obj2)
}


result = processInput([16,1,2,0,4,2,7,1,2,14])
console.log('result',result)
if (!compare(result, {position: 2, total_fuel_cost: 37})) {
    throw result
}