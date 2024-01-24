Select *
From portfolioproject..CovidDeaths$
where continent is not null
order by 3,4


--Select *
--From portfolioproject..CovidVaccination$
--order by 3,4

---To select data
Select Location, date, total_cases, new_cases, total_deaths, population
From portfolioproject..CovidDeaths$
where continent is not null
order by 1,2

--- Looking at Total Cases vs Total Deaths
--- show likelihood of dying if contract dovid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From portfolioproject..CovidDeaths$
where Location like '%states%'
where continent is not null
order by 1,2

--- Looking at the total Cases vs Population
--- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfection
From portfolioproject..CovidDeaths$
where Location like '%states%'
where continent is not null
order by 1,2

--- Looking at countries with Highest Infection Rate Compared to population

Select Location, population, Max(total_cases) as HighestInfectioncount, Max(total_cases/population)*100 as 
  PercentPopulationInfection
From portfolioproject..CovidDeaths$
  ---where Location like '%states%'
  where continent is not null
Group by Location, population
order by PercentPopulationInfection desc




--- Showing countries with Highest Death Count Per Population

Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths$
  ---where Location like '%states%'
  where continent is  null
Group by Location 
order by TotalDeathCount desc


--- To break things down by Continent

--- Showing continents with the highest death count per population

Select Continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths$
  ---where Location like '%states%'
  where continent is not null
Group by continent
order by TotalDeathCount desc




--- Global numbers

Select Sum(new_cases) as Total_Cases, Sum(Cast(new_deaths as int)) as Total_Deaths, Sum(Cast(new_deaths as int))/Sum
  (new_cases)*100 as Deathpercentage
From portfolioproject..CovidDeaths$
---where Location like '%states%'
where continent is not null
---Group by date
order by 1,2

---- looking at the Total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
  dea.date) as Rollingspeoplevaccinated
---(Rollingspeoplevaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccination$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

---CTE

with popvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
  dea.date) as Rollingpeoplevaccinated
---(Rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccination$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)
select *, (Rollingpeoplevaccinated/Population)*100
from popvsVac



---- Temp Table
Drop Table if exists  #PerPopulationVaccinated
Create Table #PerPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PerPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
  dea.date) as Rollingpeoplevaccinated
---(Rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccination$ vac
   on dea.location = vac.location
   and dea.date = vac.date
---where dea.continent is not null
---order by 2,3


select *, (Rollingpeoplevaccinated/Population)*100
from #PerPopulationVaccinated




----create view to store dat for later visualization

Create view PerPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location Order by dea.location,
  dea.date) as Rollingpeoplevaccinated
---(Rollingpeoplevaccinated/population)*100
from portfolioproject..CovidDeaths$ dea
join portfolioproject..CovidVaccination$ vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
---order by 2,3

select * 
from PerPopulationVaccinated
