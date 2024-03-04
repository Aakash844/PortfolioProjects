select *
from project..CovidDeaths$
where continent is not null
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from project..CovidDeaths$
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths$
where location like '%state%'
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from project..CovidDeaths$
where location like '%india%'
order by 1,2

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentagePopulationInfected
from project..CovidDeaths$
--where location like '%india%'
group by location, population
order by PercentagePopulationInfected desc

select location,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths$
--where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc

select location,max(cast(total_deaths as int)) as TotalDeathCount
from project..CovidDeaths$
--where location like '%india%'
where continent is null
group by location
order by TotalDeathCount desc


select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..CovidDeaths$
where continent is not null
order by 1,2



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


--Temp Table
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
