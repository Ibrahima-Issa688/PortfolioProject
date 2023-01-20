SELECT *
FROM CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4

--select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

--Looking at the total cases VS total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths$
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE location LIKE '%China%'
ORDER BY 1,2

--Looking at the total cases VS the population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Cases_Percentage
FROM CovidDeaths$
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS US_Cases_Percentage
FROM CovidDeaths$
WHERE location LIKE '%States%'
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS China_Cases_Percentage
FROM CovidDeaths$
WHERE location LIKE '%China%'
ORDER BY 1,2

--Looking at Country with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) AS Total_Infection_Count, (MAX(total_cases)/population)*100 AS Infection_Rate
FROM CovidDeaths$
GROUP BY location, population
ORDER BY 4 DESC

-- Show Highest Death Count Rate

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
GROUP BY location
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE location NOT IN ('World', 'Europe', 'North America', 'European Union', 'South America', 'Asia','Africa')
GROUP BY location
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Let's break it by Continent

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC

-- Showing Continent with the Highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IN ('Africa')
GROUP BY location 
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IN ('North America')
GROUP BY location 
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IN ('South America')
GROUP BY location 
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IN ('Europe')
GROUP BY location 
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IN ('Asia')
GROUP BY location 
ORDER BY 2 DESC

SELECT location, MAX(CAST(total_deaths as int)) AS Total_Death_Count 
FROM CovidDeaths$
WHERE continent IN ('Oceania')
GROUP BY location 
ORDER BY 2 DESC

-- Global Numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2 

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2 


SELECT *
FROM CovidVaccinations$
ORDER BY 1
 
-- Looking at Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths$ AS dea
Join CovidVaccinations$ AS vac
     On dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

--Partition by location

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM CovidDeaths$ AS dea
Join CovidVaccinations$ AS vac
     On dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM CovidDeaths$ AS dea
Join CovidVaccinations$ AS vac
     On dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (rolling_people_vaccinated/population)*100 AS Percentage_of_Vaccinated_Pop
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated  

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
) 

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM CovidDeaths$ AS dea
Join CovidVaccinations$ AS vac
     On dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100 AS Percentage_of_Vacc_Pop
FROM #PercentPopulationVaccinated


--Creating Views to store date for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM CovidDeaths$ AS dea
Join CovidVaccinations$ AS vac
     On dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

