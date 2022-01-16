/* Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY location, date



-- Select data that I will be starting with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY location, date



-- The Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null 
ORDER BY Location, date



-- Looking at the Total Cases vs Population
--Shows the percetnage of population infect with COVID in United States
SELECT Location, date, population, total_cases, (total_cases/population)* 100 as PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY Location, date

-- Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as PopulationInecfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PopulationInecfectedPercentage desc



-- Looking at Countires with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY TotalDeathCount desc



-- BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY total_cases, total_deaths



-- Total Population vs. Vaccinations
-- Percentage of Population that has gotten at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by location, date




-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store later for visualizations 
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 


-- Creating View to store later for visualizations looking at Countires with Highest Death Count per Population
Create View TotalDeathCountByCountry as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location