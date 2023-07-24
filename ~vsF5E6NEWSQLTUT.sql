select *
from CovidInfo..cviddeathsnew
where continent is not null
order by 3,4

select *
from CovidInfo..covidvaccinationdata
order by 3,4

--total cases vs tvtal deaths
select location,date,total_cases,total_deaths,
(cast (total_deaths as int)/cast(total_cases as int)*100)
from CovidInfo..cviddeathsnew
where continent is not null
order by 1,2

--total cases vs population
select location,date,total_cases,population
,(cast (total_cases as int)/cast(population as int)*100)
as deathpercentage
from CovidInfo..cviddeathsnew
where continent is not null and location like '%states%'
order by 1,2

--creating view to store data
create view deathpercentage as

--looking at countries with highest infection rates
select location,population,max(total_cases) as highestinfectioncount
,max(cast (total_cases as bigint)/cast(population as bigint)*100)
as highestcount
from CovidInfo..cviddeathsnew
where continent is not null
group by population,location
--order by highestcount

--looking at countries with highest infection death count
select location,max( cast (total_deaths as int)) as totalDeathCount
from CovidInfo..cviddeathsnew
where continent is not null
group by continent
order by totalDeathCount desc

--breakdwn by continent
select location,max( cast (total_deaths as int))
as totalDeathCount
from CovidInfo..cviddeathsnew
where continent is not null
group by continent
order by totalDeathCount desc

--showing the continent with the highest death count
select location,max( cast (total_deaths as int))
as totalDeathCount
from CovidInfo..cviddeathsnew
where continent is not null
group by location
order by totalDeathCount desc

--global numbers
select date, sum(cast(new_cases as int)) as totalCases,
sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 
as deathPercentage
from CovidInfo..cviddeathsnew
--where continent is not null and location like '%states%'
group by date
order by 1,2

--use cte--total vac
with PopsVac (continent,location,date,population,
new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplevaccinated
from CovidInfo..cviddeathsnew as dea
join CovidInfo..covidvaccinationdata vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from PopsVac

--temp table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
newVaccination numeric,
rollingPeopleVaccinated numeric
)
insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplevaccinated
from CovidInfo..cviddeathsnew as dea
join CovidInfo..covidvaccinationdata vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100
from #percentPopulationVaccinated

--creating view to store data
create view percentPopulationVaccinated as
select dea.continent,dea.location,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) 
over (partition by dea.location order by dea.location,dea.date) as 
rollingpeoplevaccinated
from CovidInfo..cviddeathsnew as dea
join CovidInfo..covidvaccinationdata vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *
from percentPopulationVaccinated