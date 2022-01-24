select *
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


--Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract Covid in your Country (United States)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

--Countries with Highest infection rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with the highest death count per population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- BY CONTINENT

-- Showing continents with highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by date
order by 1,2

--Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 1, 2, 3

	--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 1, 2, 3
	)
	select *, (RollingPeopleVaccinated/population)*100
	from PopvsVac

--Temp Table

drop table if exists #PercentPopVac
create table #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentPopVac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 1, 2, 3
		select *, (RollingPeopleVaccinated/population)*100
	from #PercentPopVac

--Creating view for later visualizaton
create view percentpopvac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 1, 2, 3



select *
from percentpopvac
