select * from covid_deaths where continent is null


select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent is not null
order by 1,2;

-- Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract the covid in your country
select location, date, total_cases,total_deaths,
		(total_deaths / total_cases * 100) as death_percentage
from covid_deaths
where location ilike '%states%'
and continent is not null
order by 1,2;

-- Looking at the total cases vs population
-- Shows what percentage of population got Covid
select location, date, population, total_cases,
		(total_cases / population * 100) as f0_percentage
from covid_deaths
where location ilike '%states%'
and continent is not null
order by 1,2;

-- Looking at countries with Highest infection rate compared to population
select location, population,
		max(total_cases) as highest_infection_count,
		max((total_cases / population * 100)) as infection_percentage
from covid_deaths
-- where location ilike '%states%'
where continent is not null
group by population, location
order by infection_percentage DESC;

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count
select continent, max(total_deaths) as highest_deaths_count
from covid_deaths
where total_deaths is not null and continent is null
group by continent
order by highest_deaths_count DESC;

-- showing countries with highest death count per population
select location, max(total_deaths) as highest_deaths_count
from covid_deaths
where total_deaths is not null and continent is null
group by location
order by highest_deaths_count DESC;

-- GLOBAL NUMBERS
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
		sum(new_deaths) / sum(new_cases) * 100 as death_rate
from covid_deaths
where total_deaths is not null and continent is not null
--group by date
order by 1,2;

-- Join new deaths table with covid vaccinations
-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location
									   order by dea.location,
									   			dea.date) 
									as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and total_vaccinations is not null
--group by dea.continent, dea.location, dea.date, dea.population
		
order by 2,3;


-- USE CTE
with PopvsVac (continent, location, date, population, 
			   new_vaccinations,rolling_people_vaccinated)
as (  
Select dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location
									   order by dea.location,
									   			dea.date) 
									as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and total_vaccinations is not null
--group by dea.continent, dea.location, dea.date, dea.population
		
order by 2,3
)
select *, (rolling_people_vaccinated / population)*100 as vaccination_percentage
from PopvsVac;


-- TEMP TABLE
DROP TABLE IF EXISTS percent_population_vaccinated
CREATE TABLE percent_population_vaccinated (
	continent varchar,
	location varchar,
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
);


INSERT INTO percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location
									   order by dea.location,
									   			dea.date) 
									as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and total_vaccinations is not null;
--group by dea.continent, dea.location, dea.date, dea.population
		
-- order by 2,3

select *, (rolling_people_vaccinated / population)*100 as vaccination_percentage
from percent_population_vaccinated;

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW view_percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations,
		sum(vac.new_vaccinations) OVER (Partition by dea.location
									   order by dea.location,
									   			dea.date) 
									as rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null and total_vaccinations is not null;
--group by dea.continent, dea.location, dea.date, dea.population
		
-- order by 2,3;

SELECT * FROM view_percent_population_vaccinated

