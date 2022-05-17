
from CovidDeaths1
where continent is not null

--looking at total cases vs Total deaths
-- likelihood of dying after contacting virus

select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths1
where location like '%Africa%'

--Total cases vs The Population

select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths1
where location like '%africa%'

--Countries with highest infection rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths1
group by location, population
order by PercentagePopulationInfected DESC

--Countries with Highest death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths1
where continent is not null
group by location
order by TotalDeathCount DESC
-- breaking it down by Continent 
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths1
where continent is  not null
group by continent
order by TotalDeathCount DESC

--Global Numbers 

select SUM(new_cases) as Total_cases , SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int ))/
SUM(new_cases)* 100 as deathpercentage
from CovidDeaths1
where continent is not null
group by date



select * 
from CovidVaccinations dea
Join CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date

	 --Looking at Total Population vs Vaccinations

with PopvsVac ( continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	 dea.date) as RollingPeopleVaccinated
from CovidDeaths1 dea
Join CovidVaccinations vac
     on dea.location = vac.location 
where dea.continent is not null
	 and dea.date = vac.date
)
select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac


---TEMP TABLE

create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	 dea.date) as RollingPeopleVaccinated
from CovidDeaths1 dea
Join CovidVaccinations vac
     on dea.location = vac.location 
where dea.continent is not null
	 and dea.date = vac.date

	 select *, (RollingPeopleVaccinated/Population) * 100
from #PercentagePopulationVaccinated

--Creating view for later Visualization 

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	 dea.date) as RollingPeopleVaccinated
from CovidDeaths1 dea
Join CovidVaccinations vac
     on dea.location = vac.location 
where dea.continent is not null
	 and dea.date = vac.date


	 select *
	 from PercentPopulationVaccinated
