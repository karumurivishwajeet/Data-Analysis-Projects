
Select * 
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null
order by 1,2

-- Total cases vs Total Deaths
-- Percentage of dying in Germany
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null and location like '%germany%'
order by 1,2

-- Total cases vs Population
-- Percentage of population infected by Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null
--where location like '%germany%'
order by 1,2


-- Countries with highest infection rate

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as InfectedPercentage
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null
--where location like '%germany%'
group by location, population
order by InfectedPercentage Desc


-- Countries with Highest Death 
Select Location,  max(cast(total_deaths as int)) as HighestDeathCount
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null
--where location like '%germany%'
group by location
order by HighestDeathCount Desc

-- Comparison by continent
-- Continents with highest death count

Select continent,  max(cast(total_deaths as int)) as HighestDeathCount
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null
group by continent
order by HighestDeathCount Desc

-- Global numbers
Select date, Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases) as DeathPercentage
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null 
group by date
order by 1,2 

Select Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/Sum(new_cases) as DeathPercentage
from [Portfolio Project].dbo.Covid_Deaths$
where continent is not null 
order by 1,2 

Select *
from [Portfolio Project].dbo.Covid_Vaccination$ 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.Covid_Deaths$ dea
join [Portfolio Project].dbo.Covid_Vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

with PopvsVac (Continent, Location, date, population,new_vaccinations, RollingPeopleVacinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.Covid_Deaths$ dea
join [Portfolio Project].dbo.Covid_Vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVacinated/population)*100
From PopvsVac


-- Temp Table

Drop table If exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Popultion numeric,
New_Vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.Covid_Deaths$ dea
join [Portfolio Project].dbo.Covid_Vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVacinated/Popultion)*100
From #PercentPopulationVaccinated


-- Creating view to store data for visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.Covid_Deaths$ dea
join [Portfolio Project].dbo.Covid_Vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
From PercentPopulationVaccinated
