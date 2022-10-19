select *
from [portfolio project]..['covid deaths$']
order by 3,4

select* 
from [portfolio project].. ['owid-covid-data (1)$']
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..['covid deaths$']
order by 1,2

 looking at total deaths vs total cases
 shows like lihood of dying in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project].. ['owid-covid-data (1)$']
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project].. ['owid-covid-data (1)$']
where location like '%india%'
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from [portfolio project].. ['owid-covid-data (1)$']
where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_deaths/total_cases))*100 as PercentPopulationInfected
from [portfolio project].. ['owid-covid-data (1)$']
--where location like '%india%'
Group by location, population
--order by 1,2
order by PercentPopulationInfected desc

--showing coutries with their highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project].. ['owid-covid-data (1)$']
--where location like '%india%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- breaking things down by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [portfolio project].. ['owid-covid-data (1)$']
--where location like '%india%'
where continent is null
Group by location
order by TotalDeathCount desc
 
 -- GLOBAL NUMBERS

select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [portfolio project].. ['owid-covid-data (1)$']
--where location like '%india%'
where continent is not null
Group by date
order by 1,2
-- death percentage across the world
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [portfolio project].. ['owid-covid-data (1)$']
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2

--looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RllingPeopleVaccinated,
 --(RollingPeopleVaccinated/population)*100
from [portfolio project]..['covid deaths$']dea
join [portfolio project]..['owid-covid-data (1)$']vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
 with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
 as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
from [portfolio project]..['covid deaths$']dea
join [portfolio project]..['owid-covid-data (1)$']vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
from [portfolio project]..['covid deaths$']dea
join [portfolio project]..['owid-covid-data (1)$']vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
from [portfolio project]..['covid deaths$']dea
join [portfolio project]..['owid-covid-data (1)$']vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 
 Select *
 From PercentPopulationVaccinated







