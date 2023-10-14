
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

Select 
      Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From 
      b9.coviddeaths c 
order by 1,2;


-- Countries with Highest Infection Rate compared to Population.

Select 
      Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From 
      b9.coviddeaths c 
Group by 
      Location, Population
order by 
       PercentPopulationInfected desc;
      
      
      
-- Countries with Highest Death Count per Population.

Select 
     Location, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount
From 
     b9.coviddeaths c
Where 
     continent is not null 
Group by 
      Location
order by 
      TotalDeathCount desc;
     
     
-- BREAKING THINGS DOWN BY CONTINENT.

-- Showing contintents with the highest death count per population.

select
      continent, MAX(cast(Total_deaths as SIGNED)) as TotalDeathCount
From 
      b9.coviddeaths c
Where 
      continent is not null 
Group by 
       continent
order by 
       TotalDeathCount desc;
      
      
-- GLOBAL NUMBERS.

Select 
      SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths, SUM(cast(new_deaths as SIGNED))/SUM(New_Cases)*100 as DeathPercentage
From 
      b9.coviddeaths c
where 
      continent is not null 
order by 1,2;


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










































