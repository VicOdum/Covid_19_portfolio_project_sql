SELECT *
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM CovidPortfolioProject..CovidVaccinations
--order by 3,4

--select Data to be used
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--total cases vs total deaths
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM CovidPortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Total cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population)*100 as Percentage_pop_infected
FROM CovidPortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Countries with highest infection rates compared to Population
SELECT Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percentage_population_infected
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
GROUP BY location, population
order by Percentage_population_infected desc

--Countries with the highest death count vs population
SELECT Location,  MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
order by Total_Death_Count desc

--breaking things down by continent

SELECT Location,  MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidPortfolioProject..CovidDeaths
where continent is null
GROUP BY location
order by Total_Death_Count desc


SELECT continent,  MAX(cast(total_deaths as int)) as Total_Death_Count
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
order by Total_Death_Count desc

--GLOBAL NUMBERS

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Percentage_pop_infected
FROM CovidPortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


SELECT date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases)/SUM(cast(new_deaths as int))*100 AS Death_Percentage
FROM CovidPortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY date
order by 1,2


SELECT sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases)/SUM(cast(new_deaths as int))*100 AS Death_Percentage
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rollin_people_vaccinated
--, (Rollin_people_vaccinated/population)*100
From CovidPortfolioProject..Coviddeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--USING CTE

With PopvsVac (continent, Location, Date, Population, new_vaccinations, Rollin_people_vaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rollin_people_vaccinated
From CovidPortfolioProject..Coviddeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (Rollin_people_vaccinated/population)*100
FROM PopvsVac






--Creating Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rollin_people_vaccinated numeric
)




Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rollin_people_vaccinated
From CovidPortfolioProject..Coviddeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (Rollin_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated


--Createing view for future visualisation
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rollin_people_vaccinated
From CovidPortfolioProject..Coviddeaths dea
join CovidPortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3