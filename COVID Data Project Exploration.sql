
----- Covid 19 Data Exploration.

----- Skills are used here: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.




Select *
From 
     project. .CovidDeaths
Where 
     continent is not null 
order by 3,4;


Select *
From 
     project. .covidvaccinations
Where 
     continent is not null 
order by 3,4;

----- Select Data going to starting with.


Select 
      Location, date, total_cases, new_cases, total_deaths, population
From 
       project. .CovidDeaths
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
    project. .CovidDeaths
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
    project. .coviddeaths
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
    project. .coviddeaths
GROUP BY
    Location, Population
ORDER BY
    PercentPopulationInfected DESC;


      
      
      
-- Countries with Highest Death Count per Population.

Select 
     Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
     project. .coviddeaths
Where 
     continent is not null 
Group by 
      Location
order by 
      TotalDeathCount desc;
     
     
-- BREAKING THINGS DOWN BY CONTINENT.

-- Showing contintents with the highest death count per population.


UPDATE project. .CovidDeaths
SET continent = CASE
    WHEN location = 'Africa' THEN 'Africa'
    WHEN location = 'Asia' THEN 'Asia'
    ELSE continent
END
WHERE (location = 'Africa' OR location = 'Asia') AND continent = '';


select continent, location
from project. .CovidDeaths;


select
      continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From 
      project. .coviddeaths
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
      project. .coviddeaths
where 
      continent is not null;




-- Total Population vs Vaccinations.

Select c.continent, c.location, c.date, c.population, v.new_vaccinations
,sum(CAST(v.new_vaccinations AS int)) over (partition by c.location order by c.location,c.date) as RollingPeopleVaccinated
from 
    project. .coviddeaths as c 
join
    project. .covidvaccinations as v
    on c.location = v.location 
    and c.date = v.date
where 
      c.continent is not null
order by 2,3;





-- Calculation on Partition By in previous query.
-- Shows Percentage of Population that has recieved at least one Covid Vaccine.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
    FROM Project. .CovidDeaths dea
    JOIN Project. .CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
    (RollingPeopleVaccinated * 100.0 / Population) as PercentVaccinated
FROM PopvsVac;











































