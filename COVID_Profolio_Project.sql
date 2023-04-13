SELECT *
FROM PortfolioProject.dbo.COVID_VACCINATIONS_1
ORDER BY 3,4

SELECT location, date, total_tests, new_tests, positive_rate
FROM PortfolioProject.dbo.COVID_VACCINATIONS_1
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows what precentage of population got COVID-19
SELECT location, date, total_tests, new_tests, (new_tests/total_tests)*100 Increase_of_Test
FROM PortfolioProject.dbo.COVID_VACCINATIONS_1
WHERE location like '%united states%'
Order by 1,2

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 PrecentOfPopulationInfected
FROM PortfolioProject.dbo.COVID_Deaths
WHERE location like '%states'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared by Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 PrecentOfPopulationInfected
FROM PortfolioProject.dbo.COVID_Deaths
--WHERE location like '%states'
GROUP BY location, population
order by PrecentOfPopulationInfected DESC


-- Showing the Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.COVID_Deaths
WHERE continent is not NULL
GROUP BY location
order by TotalDeathCount DESC


-- Breaking Down By Continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.COVID_Deaths
WHERE continent is NULL
GROUP BY location
order by TotalDeathCount DESC


-- Global Numbers

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/NullIf(SUM(new_cases),0) *100 DeathPercentage
FROM PortfolioProject.dbo.COVID_Deaths
WHERE continent is not null
--Group by DATE
order by 1,2

-- Looking at Totla Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..COVID_Deaths dea
JOIN PortfolioProject..COVID_VACCINATIONS_1 vac
    ON dea.location = vac.LOCATION
    AND dea.date = vac.DATE
where dea.continent is not null
order by 2,3

--Use CTE

With PopVsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..COVID_Deaths as dea
JOIN PortfolioProject..COVID_VACCINATIONS_1 as vac
    ON dea.location = vac.LOCATION
    AND dea.date = vac.DATE
where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
From PopVsVac


-- TEMP Table
--DROP Table if exists #Precent_Population_Vaccinated
Create Table #Precent_Population_Vaccinated
(
Continent nvarchar(225),
location nvarchar(225),
date datetime,
population float,
new_vaccinations float,
Rolling_People_Vaccinated float
)

INSERT INTO #Precent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..COVID_Deaths as dea
JOIN PortfolioProject..COVID_VACCINATIONS_1 as vac
    ON dea.location = vac.LOCATION
    AND dea.date = vac.DATE
where dea.continent is not null
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #Precent_Population_Vaccinated

-- Creating view to store data for later visualizations

CREATE VIEW Precent_Population_Vaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..COVID_Deaths as dea
JOIN PortfolioProject..COVID_VACCINATIONS_1 as vac
    ON dea.location = vac.LOCATION
    AND dea.date = vac.DATE
where dea.continent is not null
--order by 2,3

Select *
From Precent_Population_Vaccinated 