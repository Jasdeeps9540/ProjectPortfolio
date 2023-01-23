
select *
from PortfolioProject..Covid_Deaths$
order by 3,4



select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject..Covid_Deaths$
order by 1,2

--Total Cases Vs Total Deaths
--Likelihood of Death from Covid in New Zealand
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths$
where location like 'New Zealand'
order by 1,2


--Total Cases vs Population
--What percentage of population got covid

select location, date, population, total_cases,(total_cases/population)*100 as CovidPercentage
from PortfolioProject..Covid_Deaths$
where location like 'New Zealand'
order by 1,2


--Countries with highest infection rate based on population

select location, population, MAX(total_cases)as Highestinfectioncount, MAX(total_cases/population)*100 as CovidPercentage
from PortfolioProject..Covid_Deaths$
Group by Location, population
order by CovidPercentage desc

--Showing Countries with the highest Death Count

select location, MAX(cast(total_deaths as int))as Totaldeathcount
from PortfolioProject..Covid_Deaths$
Where continent is not null
Group by Location
order by Totaldeathcount desc

--Showing Continents with the highest Death Count

select continent, MAX(cast(total_deaths as int))as Totaldeathcount
from PortfolioProject..Covid_Deaths$
Where continent is not null
Group by continent
order by Totaldeathcount desc


--Joining the Tables

select *
from PortfolioProject..Covid_Deaths$ dea
join PortfolioProject..Covid_Vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date

--Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinations
from PortfolioProject..Covid_Deaths$ dea
join PortfolioProject..Covid_Vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3


--Using CTE for Percentage of Vaccinated based on Population

With PopvsVac (Continent, Location, Date, Population, New_vaccination, RollingVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinations
from PortfolioProject..Covid_Deaths$ dea
join PortfolioProject..Covid_Vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
)
Select *, (RollingVaccinations/Population)*100 as VaccinationPercentage
from PopvsVac
order by 2,3



--Temp Table

--Drop Table if exists #VaccinationTable
Create Table #VaccinationTable
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingVaccinations numeric,
)

Insert Into #VaccinationTable
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinations
from PortfolioProject..Covid_Deaths$ dea
join PortfolioProject..Covid_Vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null

	Select *, (RollingVaccinations/Population)*100 as VaccinationPercentage
from #VaccinationTable
order by 2,3


--Creating View for data visualisation

Create view VaccinationTable as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingVaccinations
from PortfolioProject..Covid_Deaths$ dea
join PortfolioProject..Covid_Vac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null