--PORTFOLIO PROJECT - COVID DATA

SELECT *
FROM  PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM  PortfolioProject..CovidVaccinations
--WHERE continent is not null
--ORDER BY 3,4

-- Select Data That We Are Using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM  PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM  PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1,2

-- Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected 
FROM  PortfolioProject..CovidDeaths
WHERE location like '%canada%'
and continent is not null
ORDER BY 1,2

-- Highest Infection Rates Compared to Populations

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected  
FROM  PortfolioProject..CovidDeaths
--WHERE location like '%canada%'
WHERE continent is not null
ORDER BY 1,2
GROUP BY population, location
ORDER BY PercentagePopulationInfected desc

-- Countries with the Highest Death Count Per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
--WHERE location like '%canada%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Breaking Things Down by Continent 
--  Showing the continents with the highest death counts 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM  PortfolioProject..CovidDeaths
--WHERE location like '%canada%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM  PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM  PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS int)) over (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use a CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS int)) over (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS int)) over (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


 -- CREATING VIEW TO STORE DATA LATER FOR VISUALISATIONS

 CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations AS int)) over (PARTITION BY dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated
