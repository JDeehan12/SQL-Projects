  /*
Covid-19 Data Exploration 

Skills Used: Joins, Temp Tables, Creating Views , Aggregate Functions, Converting Data Types and Common Table Expressions (CTEs)
*/

/* This data was made availabe by:
Hannah Ritchie, Edouard Mathieu, Lucas Rodés-Guirao, Cameron Appel, Charlie Giattino, Esteban Ortiz-Ospina, Joe Hasell, Bobbie Macdonald, Diana Beltekian and Max Roser (2020) - "Coronavirus Pandemic (COVID-19)". 
Published online at OurWorldInData.org. Retrieved from: 'https://ourworldindata.org/coronavirus' [Online Resource]
*/


-- Taking a look at the available data

SELECT *
FROM CovidDataExploration..CovidDeaths
ORDER BY 3,4


-- Select Data that we are going to be starting with (excluding NULL values in "continent" column)

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid-19 in South Africa

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE location LIKE '%south africa%'
AND continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid-19 in every country

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDataExploration..CovidDeaths
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDataExploration..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count by Population

SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count by population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDataExploration..CovidDeaths deaths
-- Changed 'SUM(CONVERT(BIGINT,vax.new_vaccinations))' to 'SUM(CONVERT(BIGINT,vax.new_vaccinations))' to avoid 'Arithmetic overflow error'
JOIN CovidDataExploration..CovidVaccinations vax
	ON deaths.location = deaths.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL 


-- Encountered "ORDER BY list of RANGE window frame has total size of 1020 bytes. Largest size supported is 900 bytes." error
-- Changing the column size of "location" to prevent error

ALTER TABLE CovidDataExploration..CovidDeaths  
ALTER COLUMN location NVARCHAR(150)


-- Retrying Total Population vs Vaccinations query

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDataExploration..CovidDeaths deaths
-- Changed 'SUM(CONVERT(BIGINT,vax.new_vaccinations))' to 'SUM(CONVERT(BIGINT,vax.new_vaccinations))' to avoid 'Arithmetic overflow error'
JOIN CovidDataExploration..CovidVaccinations vax
	ON deaths.location = deaths.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL 


-- Using CTE to perform a calculation on 'Partition By' in previous query

WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDataExploration..CovidDeaths deaths
JOIN CovidDataExploration..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Using a Temporary Table to perform calculations on 'Partition By'

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDataExploration..CovidDeaths deaths
JOIN CovidDataExploration..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date


-- Checking Temp Table '#PercentPopulationVaccinate'

SELECT *
FROM #PercentPopulationVaccinated


-- Creating a View to store data for later use

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations
, SUM(CONVERT(BIGINT,vax.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
FROM CovidDataExploration..CovidDeaths deaths
JOIN CovidDataExploration..CovidVaccinations vax
	ON deaths.location = vax.location
	AND deaths.date = vax.date
WHERE deaths.continent IS NOT NULL



/*
Queries used for Tableau Visualizations
*/


-- 1. TOTAL WORLWIDE CASES, DEATHS AND DEATH PERCENTAGES 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- 2. TOTAL DEATH COUNT PER CONTINENT

SELECT location, SUM(CAST(new_deaths AS INT )) AS TotalDeathCount
FROM CovidDataExploration..CovidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3. HIGHEST PERCENTAGE OF PEOPLE INFECTED PER COUNTRY

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDataExploration..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4. PERCENTAGE OF PEOPLE INFECTED PER COUNTRY

SELECT location, population,date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDataExploration..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC
