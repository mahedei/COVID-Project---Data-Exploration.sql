---- Queries used for Tableau Project.


-- 1. (total_cases, total_deaths, DeathPercentage.)

SELECT 
    SUM(CAST(new_cases AS INT)) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(CAST(new_cases AS INT)), 0) AS DeathPercentage
FROM project. .CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases, total_deaths;


---2.(Group=Continent, TotalDeathCount DESC.)

SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM project. .CovidDeaths
----where location like '%states%'
-----where continent is null
---- and location not in ('World', 'European Union', 'International')
GROUP BY continent
HAVING SUM(CAST(new_deaths AS INT)) > 0
ORDER BY TotalDeathCount DESC;



-- 3.(population , HighestInfectionCount, PercentPopulationInfected)


SELECT
    Location,
    Population,
    date,
    MAX(CAST(total_cases AS BIGINT)) AS HighestInfectionCount,
    CASE
        WHEN CAST(Population AS BIGINT) = 0 THEN NULL
        ELSE MAX(CAST(total_cases AS BIGINT) * 100.0 / NULLIF(CAST(Population AS BIGINT), 0))
    END AS PercentPopulationInfected
FROM project. .CovidDeaths
-- WHERE Location LIKE '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC;



-- 4.(continent, location, date, population, RollingPeopleVaccinated.)

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project. .CovidDeaths dea
Join project. .CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3;



-- 5. (MaxPopulation, PercentPopulationInfected, HighestInfectionCount, location.)

SELECT
    location,
    MAX(CAST(total_cases AS bigint)) AS HighestInfectionCount,
    CASE 
        WHEN MAX(CAST(population AS bigint)) = 0 THEN NULL
        ELSE MAX(CAST(total_cases AS bigint)) * 100.0 / MAX(CAST(population AS bigint))
    END AS PercentPopulationInfected,
    MAX(CAST(population AS bigint)) AS MaxPopulation
FROM
    project. .CovidDeaths
GROUP BY
    location
ORDER BY
    PercentPopulationInfected DESC;







