use Portofolio_Project;

SELECT * FROM covid_death
WHERE continent2 = 'Asean'
ORDER BY date;

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM covid_death
WHERE location = 'Indonesia'
ORDER BY date;

-- Total Cases vs Populations
SELECT Location, Date, Population, Total_cases, (total_cases/population)*100 AS Confirmed_Percentage
FROM covid_death
WHERE location = 'Indonesia'
ORDER BY date;

-- Countries with Highest Infection Rate compared to Population in ASEAN country
SELECT location, population, MAX(total_cases) AS Highets_Infection_Rate, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM covid_death
WHERE continent2 = 'Asean'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC;

--showing countries with highest death count per population in ASEAN
SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count, (MAX(total_deaths)/MAX(total_cases))*100 AS Death_Percentage
FROM covid_death
WHERE continent2='Asean'
GROUP BY location
ORDER BY Total_Death_Count DESC;


-- ASEAN New Cases and Death per Day
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Death --, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
FROM covid_death
WHERE continent2 = 'Asean'
GROUP BY date
ORDER BY date;


-- VACCINATIONS
SELECT * FROM covid_vaccinations;

-- Total Population vs Vaccinations in ASEAN Country
SELECT death.continent2, death.Location, death.date, death.Population, vac.New_Vaccinations, 
	   SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Cumulative_Of_Vaccinated
FROM covid_death death JOIN covid_vaccinations vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent2 = 'Asean'
ORDER BY 2,3;


-- Total Population vs Vaccinations in ASEAN Country with CTE
WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, Cumulative_of_Vaccinated) AS
(
SELECT death.continent2, death.Location, death.date, death.Population, vac.New_Vaccinations, 
	   SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Cumulative_Of_Vaccinated
FROM covid_death death JOIN covid_vaccinations vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent2 = 'Asean'
)
SELECT *, (Cumulative_of_Vaccinated/Population)*100 AS Percentage_of_Vaccinated FROM PopVsVac



-- TEMP TABLE
DROP TABLE IF EXISTS Percent_Population_Vaccinated
CREATE TABLE Percent_Population_Vaccinated (
Continent varchar(255),
Location varchar(255),
Date datetime,
Population int,
New_Vaccinations int,
Cumulative_of_Vaccinated float
)

insert into Percent_Population_Vaccinated
SELECT death.continent2, death.Location, death.date, death.Population, vac.New_Vaccinations, 
	   SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Cumulative_Of_Vaccinated
FROM covid_death death JOIN covid_vaccinations vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent2 = 'Asean'

-- Create view for preparation Data Visualization
Create view	Percentage_Population_Vaccinated AS
SELECT death.continent2, death.Location, death.date, death.Population, vac.New_Vaccinations, 
	   SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS Cumulative_Of_Vaccinated
FROM covid_death death JOIN covid_vaccinations vac
ON death.location = vac.location
AND death.date = vac.date
WHERE death.continent2 = 'Asean'



-- Query for Tableau Dashnboard

-- 1. Death Rate (Percentage) of COVID-19 in ASEAN

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_death
--Where location like '%states%'
where continent2 = 'Asean' 
--Group By date
order by 1,2


-- 2. Count of Death COVID19 in ASEAN

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From covid_death
--Where location like '%states%'
Where continent2 = 'Asean'
Group by location
order by TotalDeathCount desc


-- 3.Percentage Confirmed Cases Compared Population

Select Location, Population, MAX(total_cases) as Confirmed_Cases,  Max((total_cases/population))*100 as Percentage_Population_Infected
From covid_death
WHERE continent2 = 'Asean'
Group by Location, Population
order by Percentage_Population_Infected desc


-- 4.Infection Rate per day

Select Location, Population, Date, MAX(total_cases) as Confirmed_Cases,  Max((total_cases/population))*100 as Percentage_Population_Infected
From covid_death
WHERE continent2 = 'Asean'
Group by Location, Population, date
order by location, date
