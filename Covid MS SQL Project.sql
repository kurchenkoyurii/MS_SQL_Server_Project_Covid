
-- This project presents SQL queries to extract, sort, 
-- and manipulate with BIG DATA, that https://ourworldindata.org/covid-deaths provides.


SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
	location, 
	date, 
	population,
	total_cases, 
	(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath
WHERE location LIKE '%Poland%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population
SELECT 
	location, 
	date, 
	population,
	total_cases, 
	(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath
ORDER BY PercentPopulationInfected DESC

SELECT 
	location, 
	population,
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath
Group by location,population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT 
		location,
		MAX(CAST(total_deaths AS INT))AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT 
	location,
	MAX(CAST(total_deaths AS INT))AS TotalDeathCount
FROM PortfolioProject..CovidDeath
WHERE continent  IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT	
		SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM 
		PortfolioProject..CovidDeath
WHERE 
		continent IS NOT NULL 
ORDER BY 
		1,2

 
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


--Using CTE(Common Table Expressions) 
WITH pop_vs_vac (
	continent, 
	location,
	date,
	population,
	new_vaccinations,
	RollingPeopleVaccinated)
AS(
	SELECT 
		dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date )  
			AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeath	dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location=vac.location
		AND dea.date=vac.date
	WHERE 
		dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RPV_Percentage
FROM pop_vs_vac


-- Using Temporary Table to perform Calculation on Partition By in previous query

--Additional dropping function if something goes wrong 
IF OBJECT_ID('#PercentPopulationVaccinated') IS NOT NULL
	DROP TABLE #PercentPopulationVaccinated
--------

CREATE TABLE #PercentPopulationVaccinated(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
		dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date )  
			AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeath	dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location=vac.location
		AND dea.date=vac.date;

SELECT *
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visualizations


--Additional dropping function if something goes wrong 
IF OBJECT_ID('PercentPopulationVaccinated') IS NOT NULL
	DROP VIEW PercentPopulationVaccinated;
--------


CREATE VIEW PercentPopulationVaccinated 
AS
	SELECT 
			dea.continent, 
			dea.location,
			dea.date,
			dea.population,
			vac.new_vaccinations,
			SUM(CONVERT(BIGINT,vac.new_vaccinations)) 
				OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date )  
				AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeath	dea
	JOIN PortfolioProject..CovidVaccinations vac
			ON dea.location=vac.location
			AND dea.date=vac.date
	WHERE 
		dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated;






