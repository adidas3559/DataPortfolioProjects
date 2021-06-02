SELECT *
FROM CovidDeaths
order by 3,4;

--SELECT *
--FROM CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the US
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location,  population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count
SELECT Location,  Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's break things down by continent
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- This is the same script but technically incorrect, it just finds the highest in each category
-- we're going with this because Alex made a mistake and we don't want to mess up the visualization. Try to fix later
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at total population vs vaccinations
--USE CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by  dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentagePeopleVaccinated
FROM PopVsVac




-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by  dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

-- It is now a save View variable
SELECT * FROM PercentPopulationVaccinated


-- Now to do it to some of the others
CREATE VIEW DeathPercentage AS
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date


CREATE VIEW LikelihoodOfDeath AS
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'


CREATE VIEW PercentPopulationInfected AS
SELECT Location, date, total_cases, population, (total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%states%'

