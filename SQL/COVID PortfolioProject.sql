SELECT*
FROM PortfolioProject.CovidDeaths
Order by 1,2;

SELECT*
FROM PortfolioProject.CovidVaccinations
Order by 1,2;

Select Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject.CovidDeaths
WHERE location LIKE '%states%'
GROUP BY 2
ORDER by 1,2;

-- Looking at total cases vs total death
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
WHERE Location LIKE '%france%'
GROUP BY date
ORDER BY location, date;

 -- Country with the highest infection rate compare to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject.CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;

 -- Showing the countries with the highest death count per population

SELECT Location, Population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE Location not in ('World', 'Europe','North America', 'South America', 'Asia', 'Africa', 'Oceania', 'European Union')
GROUP BY Location, Population
ORDER BY TotalDeathCount desc;

 --- Let's break things down by contient


SELECT Continent, Population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE Continent is not null
GROUP BY Continent
ORDER BY TotalDeathCount desc;

 -- Showing the contient with the highest death count per population

SELECT Continent, Population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject.CovidDeaths
WHERE Continent is not null
GROUP BY Continent
ORDER BY TotalDeathCount desc;

 -- GLOBAL NUMBERS : contrairement à Bootcamp on ne peut pas classer avec Contient Not Null car ils 
  -- sont tous renseignés, il faut exclure les contients le nombre de morts est compté sur Chaque pays + 
  -- le contient + world (ex: 98 nouveaux cas en Asie au total le 23/01/2020 compté 294 car aussi sur 
  -- continent Asie et World)

 -- Find the death percentage 

SELECT SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.CovidDeaths
WHERE Location not in ('World', 'Europe','North America', 'South America', 'Asia', 'Africa', 'Oceania', 'European Union')
ORDER BY 1,2;

 -- Looking at total population vs Vaccinations in Albania

SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS SIGNED)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv 
On cd.location = cv.location
and cd.date = cv.date
WHERE cd.Location = 'Albania' 
order BY cd.location, cd.date;

-- Add a CTE to then use the result of the Query and compare it to the population to know with % of population is vaccinated

WITH PopvsVac(Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS SIGNED)) OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv 
On cd.location = cv.location
and cd.date = cv.date
WHERE cd.Location = 'Albania' 
)
Select*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- Same case with a Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated

CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Location varchar(255),
Date datetime,
Population bigint,
New_vaccinations int NULL,
RollingPeopleVaccinated int NULL
);

Insert into PercentPopulationVaccinated
SELECT cd.location, cd.date, cd.population,
NULLIF(cv.new_vaccinations, '') AS new_vaccinations,
SUM(CAST(NULLIF(cv.new_vaccinations, '') AS SIGNED))
OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv 
On cd.location = cv.location
and cd.date = cv.date
WHERE cd.Location = 'Albania'

Select*, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated

-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT cd.location, cd.date, cd.population,
NULLIF(cv.new_vaccinations, '') AS new_vaccinations,
SUM(CAST(NULLIF(cv.new_vaccinations, '') AS SIGNED))
OVER (Partition by cd.Location Order by cd.location, cd.date) as RollingPeopleVaccinated
FROM PortfolioProject.CovidDeaths cd 
JOIN PortfolioProject.CovidVaccinations cv 
On cd.location = cv.location
and cd.date = cv.date
WHERE cd.Location = 'Albania'

SELECT*
FROM PercentPopulationVaccinated
