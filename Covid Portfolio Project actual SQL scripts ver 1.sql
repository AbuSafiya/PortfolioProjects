--select *
--from PortfolioProject..CovidDeaths
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2



--- Looking at Total cases vs Total Deaths
--- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
order by 1,2


---Looking at Total cases vs Population
---Shows what percentage of population got Covid

select location, date,population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location = 'Kazakhstan'
order by 1,2

--- Looking at countries with Highest Infection Rate compared to Population

select location,population, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'Kazakhstan'
group by location,population
order by PercentPopulationInfected desc


--- Showing countries with the Highest Death Count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Kazakhstan'
where continent is not null
group by location,population
order by TotalDeathCount desc


--- Breaking down things by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Kazakhstan'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing continents with Highest Death Count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Kazakhstan'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as INT)) as total_death,sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentageGlobally
from PortfolioProject..CovidDeaths
--where location = 'Kazakhstan'
where continent is not null
group by date
order by 1,2

-- Global Numbers Total
select SUM(new_cases) as total_cases, sum(cast(new_deaths as INT)) as total_death,sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentageGlobally
from PortfolioProject..CovidDeaths
--where location = 'Kazakhstan'
where continent is not null
--group by date
order by 1,2



-- total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 To find how many people vaccoinated in certain country
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 To find how many people vaccoinated in certain country
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
where location = 'Kazakhstan'



--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 To find how many people vaccoinated in certain country
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
where location = 'Kazakhstan')


-- Creating View to store for later visulaization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 To find how many people vaccoinated in certain country
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2,3

select * 
from PercentPopulationVaccinated