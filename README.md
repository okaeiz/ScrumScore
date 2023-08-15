# Scrum Adherence Score Calculator for Cultural Institutions

A comprehensive tool designed to calculate an overall Scrum adherence score for different groups within a cultural institution. Built upon the principles of the Scrum methodology and the Taiga platform, this calculator ensures that each group's commitment and performance with respect to Scrum are quantified.

## Table of Contents
- [Background](#background)
- [Parameters](#parameters)
- [Formula Evolution](#formula-evolution)
- [Repository Contents](#repository-contents)
- [Usage](#usage)
- [Contribute](#contribute)


## Background

The Scrum Adherence Score Calculator emerged from the need to quantify the adherence of various groups within a cultural institution to the Scrum methodology. With the parameters and formula continually refined, this tool serves as a reliable metric of Scrum commitment.

## Parameters

1. **Sprint Planning (Factor A)**:
    - **Description**: Evaluates the team's commitment for a sprint.
    - **Formula**: `ratio of the story points of current sprint to the total number of hours committed by the team`
    
2. **Progress (Factor B)**:
    - **Description**: Gauges the task completion rate within a sprint.
    - **Formula**: `ratio of the done task points to the story points of the current sprint`
    
3. **Scrum Meetings (Factor C)**:
    - **Description**: Assesses the quality and consistency of daily Scrum meetings.
    - **Formula**: `average score of daily scrum meetings`
    
4. **Release (Factor D)**:
    - **Description**: Determines the success rate of user story completions in a sprint.
    - **Formula**: `ratio of the story points of completed user stories to the total story points of the current sprint`

## Formula Evolution

[This section](https://docs.google.com/document/d/1C2Dp8DS4XJ6Q252b2aLyR4glQ-CHptWlRDdlIBfs6ng/edit#heading=h.1ta9kqkjujm9) provides a history of the various changes made to both the parameters and the overarching formula. By documenting the iterative refinement process, we ensure transparency and traceability in our methodology.

## Repository Contents

- **SQL Queries**:
    - [Factor A Query](https://github.com/okaeiz/ScrumScore/blob/main/A%20factor.sql)
    - [Factor B Query](link-to-factor-B-query)
    - [Factor C Query](https://github.com/okaeiz/ScrumScore/blob/main/C%20factor.sql)
    - [Factor D Query](https://github.com/okaeiz/ScrumScore/blob/main/D%20factor.sql)
    
- **Python Script**: [Final Score Calculator](link-to-python-script)

## Usage

1. Execute the SQL queries for Factors A, B, C, and D.
2. Feed the results into the Python script.
3. Run the script to get the final Scrum Adherence Score.

Detailed steps can be found in the [usage guide](https://docs.google.com/document/d/1C2Dp8DS4XJ6Q252b2aLyR4glQ-CHptWlRDdlIBfs6ng/edit#heading=h.o1j4rmhg8qcc) or inline instructions in the Python script.

## Contribute

Contributions, feedback, and improvements are welcome. To contribute:
1. Fork the repository.
2. Create a new branch.
3. Submit your changes with a descriptive commit message.
4. Open a pull request.


