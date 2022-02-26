--Select Data That im going to use
Select  location, date, total_cases, new_cases, total_deaths, population
from Protfolioproject..coviddeaths
where continent is not null
order by 1,2

-- total cases vs total deaths

Select  location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_precentage
from Protfolioproject..coviddeaths
where location ='israel'
order by 1,2

--total case vs population

Select  location, date, total_cases, population,(total_deaths/population)*100 as death_precentage
from Protfolioproject..coviddeaths
where location ='israel'
order by 1,2

-- loking at countries with highest infaction rate compared to population

Select  location, population, max(total_cases) as highest_infactioncount, max((total_cases/population))*100 as populatopn_infected
from Protfolioproject..coviddeaths
group by location, population
order by populatopn_infected desc

-- countries with highest death count per population 
Select  location, max(cast(total_deaths as int)) as total_deathcount
from Protfolioproject..coviddeaths
where continent is not null
group by location 
order by total_deathcount desc

-- death count by continent
Select  continent, max(cast(total_deaths as int)) as total_deathcount
from Protfolioproject..coviddeaths
where continent is not null 
group by continent 
order by total_deathcount desc

--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as desthprecentage
from Protfolioproject..coviddeaths
where continent is not null 
order by 1,2

--looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Protfolioproject..coviddeaths dea
Join Protfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Protfolioproject..coviddeaths dea
Join Protfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select*,(rollingpeoplevaccinated/population)*100
from popvsvac


-- using temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations float,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Protfolioproject..coviddeaths dea
Join Protfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date

	create view RollingPeopleVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Protfolioproject..coviddeaths dea
Join Protfolioproject..covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


create view globalpopulation as

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as desthprecentage
from Protfolioproject..coviddeaths
where continent is not null 

create view totalcasevspopulation as

Select  location, date, total_cases, population,(total_deaths/population)*100 as death_precentage
from Protfolioproject..coviddeaths
where location ='israel'
 