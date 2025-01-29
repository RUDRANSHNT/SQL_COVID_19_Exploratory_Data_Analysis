Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the Probability of dying if you contract COVID in your country

Select location, date, total_cases, total_deaths, CAST(total_deaths as float) / CAST(total_cases as float)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
Order By 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population contracted COVID

Select location, date, Population, total_cases, CAST(total_cases as float) / CAST(population as float)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Order By 1,2

-- Looking at countries with the highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float) / CAST(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location, population
Order By PercentPopulationInfected desc

-- Showing the Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by Location
Order By TotalDeathCount desc

-- Showing the Total deaths due to COVID by Continents

-- Showing Continents with the Highest Death Count per Population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by continent
Order By TotalDeathCount desc

-- Global Figures

Select date, SUM(total_cases), SUM(total_deaths), SUM(total_deaths)/SUM(total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by date
Order By 1,2

--Come back to this query

-- Looking at the Total Population vs Total Vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date)
as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Inner Join PortfolioProject..CovidVaccinations as vacc
   On deaths.location = vacc.location
   and deaths.date = vacc.date
Where deaths.continent is not null
order by 2,3

-- Using CTE (Common table expression)

With PopvsVacc (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)

as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date)
as RolingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Inner Join PortfolioProject..CovidVaccinations as vacc
   On deaths.location = vacc.location
   and deaths.date = vacc.date
Where deaths.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVacc

-- Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(100),
Location nvarchar(100),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentagePopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date)
as RolingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Inner Join PortfolioProject..CovidVaccinations as vacc
   On deaths.location = vacc.location
   and deaths.date = vacc.date
Where deaths.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

-- Creating View to store data for Visualizations

Create View PercentagePopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CONVERT(float, vacc.new_vaccinations)) over (Partition by deaths.location order by deaths.location, deaths.date)
as RolingPeopleVaccinated
From PortfolioProject..CovidDeaths as deaths
Inner Join PortfolioProject..CovidVaccinations as vacc
   On deaths.location = vacc.location
   and deaths.date = vacc.date
Where deaths.continent is not null
--order by 2,3
