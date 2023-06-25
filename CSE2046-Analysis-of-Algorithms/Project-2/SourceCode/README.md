A sample run of the half traveling salesman algorithm is as follows:

> python half_tsp.py sample-input-1.txt sample-output-1.txt

Half TSP Solver
This repository contains an implementation of a solver for the Half Traveling Salesman Problem (Half TSP). 
The Half TSP is a variant of the classic Traveling Salesman Problem, 
where the objective is to find the shortest possible route that visits exactly half of the cities and returns to the starting city.

Problem Description
Given a list of cities and the distances between each pair of cities, 
the goal is to find a tour that visits exactly half of the cities and returns to the starting city, 
minimizing the total distance traveled. The distance between two cities is calculated using the Euclidean distance formula.

Solution Approach
Our solution approach is based on a heuristic algorithm that combines the nearest neighbor algorithm with local search heuristics. 
The algorithm starts with an initial city and iteratively selects the nearest unvisited city until half of the cities are visited. 
Local search heuristics are incorporated to improve the quality of the solution obtained by the nearest neighbor algorithm.

Requirements
To run the code, you need to have Python (version 3.6 or higher) installed on your system.

Usage

Prepare an input file with the city data in the following format:
city_id x_coordinate y_coordinate
your input file name should be : input.txt

Run the hw.py script with the path to the input file as the command line argument:
python hw.py 

The program will output the tour solution into a file named output.txt in the following format:

total_distance
city_id_1
city_id_2
...
city_id_n

The first line indicates the total distance of the tour, followed by the city IDs in the order they are visited.

Examples
Example input and output files are provided in the examples directory. You can use these files as a reference to understand the input format and the expected output.

Performance
The algorithm is designed to work efficiently for problem instances with up to 50,000 cities. However, the runtime may vary depending on the size of the input and the computational resources available.