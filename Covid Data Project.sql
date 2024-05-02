

select *
from PortfolioProject1CovidDeaths..CovidDeaths
--Where datalength(continent) > 0
order by 3,4

--select *
--from PortfolioProject1CovidDeaths..CovidDeaths
--order by 3,4

--Select Data that we will be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1CovidDeaths..CovidDeaths
order by 1,2

-- looking at total cases vs. total deaths
-- shows likelihood of dying if you get covid in each country
select location, date, total_cases, total_deaths, (total_deaths / CAST (total_cases as int))*100 as DeathPercentage
from PortfolioProject1CovidDeaths..CovidDeaths
where location like 'Ecuador'
order by 1,2

-- looking at population vs. total cases
-- shows likelihood getting covid in each country
select location, date, population, total_cases, (total_cases / population)*100 as InfectionPercentage
from PortfolioProject1CovidDeaths..CovidDeaths
--where location like 'Ecuador'
order by 1,2

-- looking at countries with highest infection rates compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))*100 as InfectionPercentage
from PortfolioProject1CovidDeaths..CovidDeaths
--where location like 'Ecuador'
Group by location, population
order by InfectionPercentage desc

-- looking at countries with highest death count compared to population
select location, MAX(CAST (total_deaths as int)) as TotalDeathCount
from PortfolioProject1CovidDeaths..CovidDeaths
--where location like 'Ecuador'
Where datalength(continent) > 0
Group by location
order by totaldeathcount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

select Continent, MAX(CAST (total_deaths as int)) as TotalDeathCount
from PortfolioProject1CovidDeaths..CovidDeaths
--where location like 'Ecuador'
Where datalength(continent) > 0
Group by continent
order by totaldeathcount desc

-- GLOBAL NUMBERS
--looking at death percentage in relation to total cases, grouped by day
Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1CovidDeaths..CovidDeaths
--where location like 'Ecuador'
Where datalength(continent) > 0 and new_cases <> 0
Group by date
order by 1,2

--looking at death percentage in relation to total cases, in total
Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1CovidDeaths..CovidDeaths
--where location like 'Ecuador'
Where datalength(continent) > 0 and new_cases <> 0
--Group by date
order by 1,2


-- Joining tables "Deaths" and "Vaccinations"
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject1CovidDeaths..CovidDeaths dea
join PortfolioProject1CovidDeaths..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where datalength(dea.continent) > 0 and dea.new_cases <> 0
order by 2,3

select *
from CovidVaccinations
order by continent, date

-- Looking at "Total Population" vs "Vaccinations"
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS INT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date ROWS UNBOUNDED PRECEDING) AS total_vaccinations
FROM
    PortfolioProject1CovidDeaths..CovidDeaths dea
JOIN
    PortfolioProject1CovidDeaths..CovidVaccinations vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
  datalength(dea.continent) > 0 
ORDER BY
    dea.location, dea.date;



	-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1CovidDeaths..CovidDeaths dea
Join PortfolioProject1CovidDeaths..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1CovidDeaths..CovidDeaths dea
Join PortfolioProject1CovidDeaths..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1CovidDeaths..CovidDeaths dea
Join PortfolioProject1CovidDeaths..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1CovidDeaths..CovidDeaths dea
Join PortfolioProject1CovidDeaths..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


/* Credits for this projects structure go to Alex The Analyst:
https://www.youtube.com/@AlexTheAnalyst
*/
