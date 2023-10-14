
----- Covid 19 Data Exploration.

----- Skills are used here: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.




Select *
From 
     b9.coviddeaths c
Where 
     continent is not null 
order by 3,4;


Select *
From 
     b9.covidvaccinations v
Where 
     continent is not null 
order by 3,4;


----- Select Data going to starting with.


Select 
      Location, date, total_cases, new_cases, total_deaths, population
From 
      b9.coviddeaths c 
Where 
      continent is not null 
order by 1,2;



-- Total Cases vs Total Death and Deathspercentage.

SELECT
    Location,
    date,
    TRY_CAST(total_cases AS float) AS total_cases,
    TRY_CAST(total_deaths AS float) AS total_deaths,
    CASE 
        WHEN TRY_CAST(total_cases AS float) = 0 THEN NULL
        ELSE (TRY_CAST(total_deaths AS float) / TRY_CAST(total_cases AS float)) * 100
    END AS DeathPercentage
FROM
    projects. .CovidDeaths
ORDER BY
    1, 2;



-- Total Cases vs Population.
-- Showing that percentage of population infected with Covid.

SELECT
    Location,
    date,
    TRY_CAST(Population AS FLOAT) AS Population,
    TRY_CAST(total_cases AS FLOAT) AS total_cases,
    CASE
        WHEN TRY_CAST(Population AS FLOAT) = 0 THEN 0
        ELSE (TRY_CAST(total_cases AS FLOAT) * 100.0) / NULLIF(TRY_CAST(Population AS FLOAT), 0)
    END AS PercentPopulationInfected
FROM
    projects. .coviddeaths
ORDER BY 1, 2;


-- Countries with Highest Infection Rate compared to Population.

SELECT
    Location,
    Population,
    MAX(CAST(total_cases AS BIGINT)) AS HighestInfectionCount,
    CASE
        WHEN CAST(Population AS BIGINT) = 0 THEN 0 -- To avoid divide by zero
        ELSE MAX(CAST(total_cases AS BIGINT)) * 100.0 / CAST(Population AS BIGINT)
    END AS PercentPopulationInfected
FROM
    projects. .coviddeaths
GROUP BY
    Location, Population
ORDER BY
    PercentPopulationInfected DESC;

      
      
      
-- Countries with Highest Death Count per Population.

Select 
     Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
     projects. .coviddeaths
Where 
     continent is not null 
Group by 
      Location
order by 
      TotalDeathCount desc;
     
     
-- BREAKING THINGS DOWN BY CONTINENT.

-- Showing contintents with the highest death count per population.

select
      continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
      projects. .coviddeaths
Where 
      continent is not null 
Group by 
       continent
order by 
       TotalDeathCount desc;

      
      
-- GLOBAL Total_cases, Total_deaths, DeathPercentage

Select 
      SUM(CAST(new_cases as INT)) as total_cases, 
      SUM(CAST(new_deaths as INT)) as total_deaths, 
      SUM(CAST(new_deaths as INT)) * 100.0 / SUM(CAST(new_cases as INT)) as DeathPercentage
From 
      projects. .coviddeaths
where 
      continent is not null;



-- Total Population vs Vaccinations.

Select c.continent, c.location, c.date, c.population, v.new_vaccinations
,sum(CAST(v.new_vaccinations AS SIGNED)) over (partition by c.location order by c.location,c.date) as RollingPeopleVaccinated
from 
    b9.coviddeaths as c 
join
    b9.covidvaccinations as v
    on c.location = v.location 
    and c.date = v.date
where 
      c.continent is not null
order by 2,3;




-- Using CTE to Calculation on Partition By in previous query.
-- Shows Percentage of Population that has recieved at least one Covid Vaccine.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select c.continent, c.location, c.date, c.population, v.new_vaccinations
,sum(CAST(v.new_vaccinations AS SIGNED)) over (partition by c.location order by c.location,c.date) as RollingPeopleVaccinated
from 
    b9.coviddeaths as c 
join
    b9.covidvaccinations as v
    on c.location = v.location 
    and c.date = v.date
where 
      c.continent is not null
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;










































