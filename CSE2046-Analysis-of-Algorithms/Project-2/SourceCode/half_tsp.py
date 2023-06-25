import math
import sys
import time


# find distance between cities
def euclidean_distance(city1, city2):
    x1, y1 = city1[1:]
    x2, y2 = city2[1:]
    return round(math.sqrt((x1 - x2) ** 2 + (y1 - y2) ** 2))


# find nearest city to current city
def find_nearest_city(current_city, unvisited_cities):
    min_distance = float('inf')
    nearest_city = None
    for city in unvisited_cities:
        distance = euclidean_distance(current_city, city)
        if distance < min_distance:
            min_distance = distance
            nearest_city = city
    return nearest_city


# main function that runs the program
def half_tsp(cities, solutionfile):
    # set the variables
    start_city = cities[0]
    unvisited_cities = cities[1:]
    current_city = start_city
    visited_cities = [current_city]

    # in while loop finds all nearest cities
    while len(visited_cities) < math.ceil(len(cities) / 2):
        nearest_city = find_nearest_city(current_city, unvisited_cities)
        visited_cities.append(nearest_city)
        unvisited_cities.remove(nearest_city)
        current_city = nearest_city

    # calculate total distance
    total_distance = sum(euclidean_distance(
        visited_cities[i], visited_cities[i+1]) for i in range(len(visited_cities)-1))
    total_distance += euclidean_distance(visited_cities[-1], start_city)

    # Write output to a text file
    with open(solutionfile, 'w') as file:
        file.write(str(total_distance) + '\n')
        for city in visited_cities:
            file.write(str(city[0]) + '\n')


def main(instancefile, solutionfile):
    start_time = time.time()
    # Read input from a text file
    cities = []
    with open(instancefile, 'r') as file:
        for line in file:
            city_id, x, y = map(int, line.strip().split())
            cities.append((city_id, x, y))

    half_tsp(cities, solutionfile)
    end_time = time.time()
    print('Execution time:', end_time-start_time, 'seconds')


main(sys.argv[1], sys.argv[2])
