

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

The Scrum Adherence Score Calculator emerged from the need to quantify the adherence of various groups or departments within a cultural institution to the Scrum methodology. With the parameters and formula continually refined, this tool serves as a reliable metric of Scrum commitment.

## Parameters

1. **Sprint Planning (Factor A)**:
    - **Function**: `fetch_a_value(pid)`
    - **Description**: Evaluates the team's commitment for a sprint.
    - **Formula**: `ratio of the story points of current sprint to the total number of hours committed by the team`
    
2. **Progress (Factor B)**:
    - **Function**: `fetch_b_value(pid, tpid)`
    - **Description**: Gauges the task completion rate within a sprint.
    - **Formula**: `ratio of the done task points to the story points of the current sprint`
    
3. **Scrum Meetings (Factor C)**:
    - **Function**: `fetch_c_value(pid)`
    - **Description**: Assesses the quality and consistency of daily Scrum meetings.
    - **Formula**: `average score of daily scrum meetings`
    
4. **Release (Factor D)**:
    - **Function**: `fetch_d_value(pid, did, cid)`
    - **Description**: Determines the success rate of user story completions in a sprint.
    - **Formula**: `ratio of the story points of completed user stories to the total story points of the current sprint`

5. **Team Raw Contribution (Factor E)**:
    - **Function**: `fetch_e_value(pid)`
    - **Description**: Determines the contribution of the team in relation to the total story points that are completed as whole in the current sprint.
    - **Formula**: `ratio of the story points of completed user stories for a specific department to the story points of completed user stories for all departments in the current sprint`

6. **Relative Team Productivity  (Factor R2)**:
    - **Function**: `fetch_r2_value(pid)`
    - **Description**: The Metric computes the average story points completed per team member of a specific project and then normalizes it by the average story points completed per team member across several projects in the organization.

## Formula Evolution

[This section](https://docs.google.com/document/d/1C2Dp8DS4XJ6Q252b2aLyR4glQ-CHptWlRDdlIBfs6ng/edit#heading=h.1ta9kqkjujm9) provides a history of the various changes made to both the parameters and the overarching formula. By documenting the iterative refinement process, we ensure transparency and traceability in our methodology.

## Repository Contents

- **SQL Queries**:
    - [Factor A Query](https://github.com/okaeiz/ScrumScore/blob/main/A%20factor.sql)
    - [Factor B Query](https://github.com/okaeiz/ScrumScore/blob/main/B%20factor.sql) 
    - [Factor C Query](https://github.com/okaeiz/ScrumScore/blob/main/C%20factor.sql)
    - [Factor D Query](https://github.com/okaeiz/ScrumScore/blob/main/D%20factor.sql)
    - [Factor E Query](https://github.com/okaeiz/ScrumScore/blob/main/E%20factor.sql)
    - [Factor R2 Query](https://github.com/okaeiz/ScrumScore/blob/main/R2%20factor.sql)
    
## Usage

1. Execute the SQL queries for Factors A through R2.
2. Create the view in the database.
3. The data shown in your visualization tool (e.g. Metabase) is now retrieved from the view and is ONLINE!

Detailed steps can be found in the [usage guide](https://docs.google.com/document/d/1C2Dp8DS4XJ6Q252b2aLyR4glQ-CHptWlRDdlIBfs6ng/edit#heading=h.o1j4rmhg8qcc) or inline instructions in the Python script.

## Contribute

Contributions, feedback, and improvements are welcome. To contribute:
1. Fork the repository.
2. Create a new branch.
3. Submit your changes with a descriptive commit message.
4. Open a pull request.

---
