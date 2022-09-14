use PortfolioProject

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
where location like '%states%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths$
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, 
max((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths$
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Popualtion
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
group by location
order by TotalDeathCount desc

select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Global Numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths$
where continent is not null
group by date
order by 1, 2

with cte as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null)
select *,
(RollingPeopleVaccinated/population)*100
from cte

-- temp table
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
Truncate table #PercentPopulationVaccinated
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated


