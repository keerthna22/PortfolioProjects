Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccination$
--order by 3,4

--Select Data that are we going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--Looking cases vs deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at total cases vs population
--Shows what percentage population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by Location,Population
Order by InfectedPercentage desc
DELETE FROM CovidDeaths$
WHERE Population IS NULL;
 
--Showing Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by Location
Order by DeathCount desc
 
-- LETS BREAK THING BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
Order by DeathCount desc

--Showing continents with highest continent
Select continent, MAX(cast(total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
Order by DeathCount desc

--GLOBAL NUMBERS

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by  date
order by 1,2

--Total cases,deaths,percentage across the world
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by  date
order by 1,2


--Looking at total population/Vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollinfPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollinfPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

-- Create temporary table to hold vaccination data
CREATE TABLE #PercentagePopulationVaccinated (
    Continent nvarchar(255),
    Date datetime,
    Location nvarchar(255),
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
	);

-- Insert data into temporary table
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent,
       dea.date,
       dea.location,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Select with the calculated percentage of population vaccinated
SELECT *,
       (RollingPeopleVaccinated / Population) * 100 AS PercentageVaccinated
FROM #PercentagePopulationVaccinated;

-- Optionally drop the temp table after use
-- DROP TABLE #PercentagePopulationVaccinated;




-- Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated as 
SELECT dea.continent,
       dea.date,
       dea.location,
       dea.population,
       vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


select * from PercentagePopulationVaccinated