/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from project..CovidDeaths$
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with
 
select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths$
order by 1,2



-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths$
where location like '%state%'
and continent is not null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from project..CovidDeaths$
where location like '%india%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
 
select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected
from project..CovidDeaths$
--where location like '%india%'
group by location, population
order by PercentagePopulationInfected desc


 -- Countries with Highest Death Count per Population
 
select location,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
 
select location,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths$
--where location like '%india%'
where continent is null
group by location
order by TotalDeathCount desc



-- GLOBAL NUMBERS
 
select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..CovidDeaths$
where continent is not null
--Group By Date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query
 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date)  as RollingPeopleVaccinated
from project..CovidDeaths$ dea
join project..vaccination$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac 




-- Using Temp Table to perform Calculation on Partition By in previous query
 
Drop Table if exists #PercentagePopulationVaccinated
Create Table  #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date)  as RollingPeopleVaccinated
from project..CovidDeaths$ dea
join project..vaccination$ vac
 on dea.location = vac.location
   and dea.date = vac.date
  --where dea.continent is not null
  --order by 2,3

  select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated




 -- Creating View to store data for later visualizations
 
create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.Date)  as RollingPeopleVaccinated
from project..CovidDeaths$ dea
join project..vaccination$ vac
 on dea.location = vac.location
   and dea.date = vac.date
  where dea.continent is not null
--order by 2,3

select *
from PercentagePopulationVaccinated
