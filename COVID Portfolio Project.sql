select *
from CovidProject..CovidDeaths
order by 3,4
WHERE continent isNULL



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER by location, date

-- Looking at the total cases vs total deaths in Singapore

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE location = 'Singapore'
ORDER by location, date DESC

-- Looking at total cases vs population
-- Shows percentage of people with covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulation
FROM CovidProject..CovidDeaths
ORDER BY location, date




--Looking at Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as maxtotalcase, MAX((total_cases/population))*100 AS death_percentage
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY death_percentage DESC



-- Showing the countries with the Highest Death Count per population

SELECT location, MAX(CAST(total_deaths as INT)) AS totaldeathcount
FROM CovidProject..CovidDeaths
where continent is not null
Group by location
order by totaldeathcount desc



-- Breaking it down by Continent

SELECT location, MAX(CAST(total_deaths as INT)) AS totaldeathcount
FROM CovidProject..CovidDeaths
where continent is null
Group by location
order by totaldeathcount desc

-- Global numbers

SELECT SUM(new_cases) as TotalCases, sum(CAST(new_deaths as INT)) as TotalDeaths, sum(CAST(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
--Group by date
Order by 1,2



-- Daily Death percentage
SELECT date, SUM(new_cases) as TotalCases, sum(CAST(new_deaths as INT)) as TotalDeaths, sum(CAST(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null
Group by date
Order by 1,2



With PopsvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3
)


Select *, (RollingPeopleVaccinated/Population)*100
FROM PopsvsVac

-- TEMP TABLE
DROP TABLE if exists
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3
)


Select *, (RollingPeopleVaccinated/Population)*100
FROM PopsvsVac


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 1,2,3

Select *
From PercentPopulationVaccinated