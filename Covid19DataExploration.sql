--1--Looking at the entire dataset; order by Location, Date
--Covid Deaths
--------------
Select *
From Covid19DataExploration.dbo.CovidDeaths
Order by 3,4

--Covid Vaccinations
--------------------
Select *
From Covid19DataExploration..CovidVaccinations
Order by 3,4


--2--Total cases vs Total Deaths (What percentage)
--------------------------------------------------
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19DataExploration..CovidDeaths
Order by 1,2



--3--This gives a rough estimate of the chances of dying if you contract COVID across regions
---------------------------------------------------------------------------------------------
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19DataExploration..CovidDeaths
Where location like '%india%'
Order by 2



--4--Total cases vs Population (Shows the percentage of population infected with Covid)
---------------------------------------------------------------------------------------
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Covid19DataExploration..CovidDeaths
Where continent is not null
Order by 1



--5--Countries with Highest Infection rate per Population percentage
--------------------------------------------------------------------
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfectedCountrywise
From Covid19DataExploration..CovidDeaths
Where continent is not null
Group by location, population
Order by 4 desc



--6--Highest death count continent wise
---------------------------------------
Select continent, max(cast(total_deaths as int)) as TotalDeathcount		
From Covid19DataExploration..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathcount desc



--7--Population infected continent wise
---------------------------------------
Select location, population, max(total_cases), max((total_cases/population))*100 as PercentPopulationInfectedContinentwise
From Covid19DataExploration..CovidDeaths
where continent is null
Group by location, population
Order by 4 desc



--8--Global numbers per date and the Death Percentage Per Cases count accross the World
---------------------------------------------------------------------------------------
Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
From Covid19DataExploration..CovidDeaths
Where continent is not null
Group by date
Order by date



--10--Global numbers; in total
------------------------------
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercenatge
From Covid19DataExploration..CovidDeaths
Where continent is not null


--11--Total population vs Total New Vaccinations per Date 
---------------------------------------------------------
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations 
From Covid19DataExploration..CovidDeaths dea
Join Covid19DataExploration..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--12--Rolling Count of people vaccinated; location and date wise
----------------------------------------------------------------
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingCountofPeopleVaccinated
From Covid19DataExploration..CovidDeaths dea
Join Covid19DataExploration..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--13--Cummulative Vaccinations VS. Total Population (Common Table Expressions)
------------------------------------------------------------------------------
With PopulationvsVaccination (Continent, Location, Date, Population, New_vaccinations, RollingCountofPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date)as RollingCountofPeopleVaccinated
From Covid19DataExploration..CovidDeaths dea
Join Covid19DataExploration..CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
Where dea.continent is not null
)
Select *, (RollingCountofPeopleVaccinated/Population)*100
From PopulationvsVaccination


--14--Temp Table
----------------
Drop Table if exists #PercentPopulationVaccinated		
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountofPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date)as RollingCountofPeopleVaccinated
From Covid19DataExploration..CovidDeaths dea
Join Covid19DataExploration..CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
Where dea.continent is not null

Select *, (RollingCountofPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--15--Views to store data for later visualization
-------------------------------------------------
--15a--Rolling People Vaccinated
---------------------------
Create view PercentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date)as RollingCountofPeopleVaccinated
From Covid19DataExploration..CovidDeaths dea
Join Covid19DataExploration..CovidVaccinations vac
on dea.date = vac.date
and dea.location = vac.location
Where dea.continent is not null

--Query
-------
Select *
From PercentPopulationVaccinated

----15b--Global Numbers
------------------
Create view GlobalNumbers as 
Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
ROUND((SUM(CAST(new_deaths as int))/SUM(new_cases)) *100,2) as DeathPercentage
From Covid19DataExploration..CovidDeaths
Where continent IS NOT NULL
Group By date

--Query
-------
Select * 
From GlobalNumbers

--15c--Continent Numbers
-------------------
Create View ContinentNumbers as
Select continent, MAX(total_cases) as HighestCaseCount, MAX(CAST(total_deaths as int)) as HighestDeathCount
From Covid19DataExploration..CovidDeaths
Where continent IS NOT NULL 
Group By continent

--Query
-------
Select * 
From ContinentNumbers

