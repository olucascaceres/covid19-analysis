--Testing importation of database 

select *
from Deaths

select *
from Vaccinations

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Deaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Deaths
where location like '%states%'
where continent is not null
order by 1,2

--Looking at total cases vs population
--Shows whats percentage of population got covid

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as covid_percentage
from Deaths
where location like '%states%'
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
--Shows whats percentage of population got covid

select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) as highets_covid_percentage
from Deaths
--where location like '%states%'
group by location, population
order by highets_covid_percentage desc 

-- Showing countries with highest deaht count per population

select location, MAX(cast(total_deaths as int)) as total_death_count
from Deaths
where continent is not null
group by location
order by total_death_count desc 

--Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as total_death_count
from Deaths
where continent is not null
group by continent
order by total_death_count desc 

--Now i gonna star the exploration of global numbers

select location, date, total_cases, total_deaths, (total_cases/population)*100 as covid_pencentage, (total_deaths/population)*100 as death_pencentage 
from Deaths
where continent is not null
order by 1,2

--Evolution of covid across the world by date

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from Deaths
where continent is not null
group by date 
order by 1,2

--Covid final numbers

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
from Deaths
where continent is not null
order by 1,2

--Looking at total population vs vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as rolling_people_vaccinated
, 
from Deaths d
Join Vaccinations v
	on d.location = v.location
	and d.date = v.date 
where d.continent is not null
order by 2,3

--Use CTE 

With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as (
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from Deaths d
Join Vaccinations v
	on d.location = v.location
	and d.date = v.date 
where d.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100
From pop_vs_vac

--TEMP TABLE

Create table Percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccianations numeric,
rolling_people_vaccinated numeric,
)

insert into Percent_population_vaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from Deaths d
Join Vaccinations v
	on d.location = v.location
	and d.date = v.date 
--where d.continent is not null

Select *, (rolling_people_vaccinated/population)*100
From Percent_population_vaccinated

--Creating view to store data for later visualizations

Create view Percent_pop_vaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(convert(int, v.new_vaccinations)) OVER (Partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from Deaths d
Join Vaccinations v
	on d.location = v.location
	and d.date = v.date 
where d.continent is not null


