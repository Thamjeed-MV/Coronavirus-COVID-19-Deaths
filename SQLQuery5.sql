
Select * 
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--Where continent is not null
--order by 3,4

--Select Data that we are going to be using


Select Location, Date, Total_cases, New_Cases,Total_deaths, Population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking for Total Cases vs Total Deaths

Select Location, Date, Total_cases,Total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking for Total Cases vs Total Deaths in India

Select Location, Date, Total_cases,Total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths$
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at Total Cases Vs Population 

Select Location, Date, Population,Total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

--Looking at Total Cases Vs Population in India

Select Location, Date, Population,Total_cases, (total_cases/Population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths$
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location,population, MAX(total_cases) as Highest_Infecteion_Count, MAX((total_cases/population))*100 as
Percent_Population_Infected
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location,population
order by  Percent_Population_Infected desc

--Showing the Countries with the Highest Death Count per Population

Select Location, MAX(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by  Total_Death_Count desc

--Showing the Countries with the Highest Death Count on the basis of Continents

Select Continent, MAX(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Continent
order by  Total_Death_Count desc

--Showing the Countries with the Highest Death Count per Population

Select Location, MAX(total_deaths) as Total_Death_Count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by  Total_Death_Count desc

--Global Numbers

Select Date,SUM(new_deaths) as Total_deaths,  SUM(new_cases) as Total_cases, 
ISNULL(SUM(new_deaths)/nullif(SUM(new_cases),0),0)*100 as Total_Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

--Total Number of Cases , Total Number of Deaths and Total Death Percentage

Select SUM(new_cases) as Total_cases,  SUM(new_deaths) as Total_deaths, 
ISNULL(SUM(new_deaths)/nullif(SUM(new_cases),0),0)*100 as Total_Death_Percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
order by 1,2


--Changing the Data Type of CovidVaccinations.new_vaccinations column to FLOAT from nvarchar

ALTER TABLE PortfolioProject..CovidVaccinations$
Alter column new_vaccinations FLOAT;


--Looking at Total Population vs Vaccination


Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(vaccine.new_vaccinations) Over (Partition by death.location Order by death.location,
death.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
Order by 2,3


--USE CTE(Common Table Expression)

With PopulationVsVaccine (Continent, Location, Date, Population,New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(vaccine.new_vaccinations) Over (Partition by death.location Order by death.location,
death.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
)
Select *, (Rolling_People_Vaccinated/Population)*100 as Percent_Vaccinated
From PopulationVsVaccine


--TEMP TABLE

Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into #Percent_Population_Vaccinated

Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(vaccine.new_vaccinations) Over (Partition by death.location Order by death.location,
death.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null

Select *, (Rolling_People_Vaccinated/Population)*100 as Percent_Vaccinated
From #Percent_Population_Vaccinated



--Creating View to store data for later visualisation

USE PortfolioProject
Go
Create View
Percent_Population_Vaccinated AS
Select death.continent, death.location, death.date, death.population,vaccine.new_vaccinations,
SUM(vaccine.new_vaccinations) Over (Partition by death.location Order by death.location,
death.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
    on death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
--Order by 2,3

Select *
From Percent_Population_Vaccinated