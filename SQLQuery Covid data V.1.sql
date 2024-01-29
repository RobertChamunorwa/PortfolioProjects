Select *
From PortfolioProject..CovidDeaths$
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--Order By 3,4

-- select Data that we are going to be using 

Select Location, date, Total_cases, new_cases, Total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- Looking at total Cases vs Total Deaths 
-- Shows Likelihood of dying if you contract covid in your country (United Kingdom)

Select Location, date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths$
where location Like 'United Kingdom'
Order by 1,2



-- Looking at Total Cases vs Population
-- Shows what percentage of United kingdoms population got Covid


Select Location, date,  population,Total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
where location Like 'United Kingdom'
Order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of United kingdoms population got Covid


Select Location, date,  population,Total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
--where location Like 'United Kingdom'
Order by 1,2


-- looking at countires with Highest Infection rate compared to Population


Select Location, population, MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
--where location Like 'United Kingdom'
Group by Location, population
Order by PercentPopulationInfected desc


-- Showing Countires with Highest Death Count per Population
-- remved the amalgamation of continetal data ' where contitnet is not null'

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location Like 'United Kingdom'
where continent is not null
Group by Location
Order by TotalDeathCount desc


-- LET'S BREAK IT DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location Like 'United Kingdom'
where continent is not null
Group by continent
Order by TotalDeathCount desc


--Global Numbers
-- The total cases and deaths globally by date

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location Like 'United Kingdom'
where continent is not null
group by date
Order by 1,2


-- The Total cases and total deaths Globally as well as the percentage 
Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location Like 'United Kingdom'
where continent is not null
--group by date
Order by 1,2



--looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated

( continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated Numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (rollingpeoplevaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to Store data for Later Visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(rollingpeoplevaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
From PercentPopulationVaccinated