-- Query 01: How many olympics games have been held?
#standardSQL
select 
	count(distinct games) as total_no_game
from
	olympics_history;
-- Query 02: List down all Olympics games held so far.
select distinct 
	oh.year,
	oh.season,
	oh.city
from 
	olympics_history oh
order by year;
-- Query 03: Mention the total no of nations who participated in each olympics game?
with all_countries as
    (select games, nr.region
    from olympics_history oh
    join olympics_history_noc_regions nr ON nr.noc = oh.noc
    group by games, nr.region)
select games, count(1) as total_countries
from all_countries
group by games
order by games;
-- Query 04: Which year saw the highest and lowest no of countries participating in olympics?
with all_countries as (
        select year, nr.region
        from olympics_history oh
        join olympics_history_noc_regions nr ON nr.noc = oh.noc
        group by year, nr.region
),
		
tot_counta as (
		select year, count(region) as total_countries
		from all_countries
		group by year
		order by year
)
select distinct
	first_value(year) over (order by total_countries) as min_year,
	first_value(total_countries) over(order by total_countries) as min_total_countries,
	first_value(year) over (order by total_countries desc) as max_year,
	first_value(total_countries) over(order by total_countries desc) as max_total_countries
from
	tot_counta
-- Query 05: Fetch the total no of sports played in each olympic games.
select
	games,
	count(distinct sport) as no_of_sports
from
	olympics_history
group by games
order by no_of_sports desc;
-- Query 06: Fetch oldest athletes to win a gold medal
with oldest as (
select
	max(cast(age as int)) as oldest_age
from
	olympics_history
where age not like '%NA%' and medal = 'Gold'
)
select
	*
from olympics_history join oldest on cast(olympics_history.age as int) = oldest.oldest_age
where age not like '%NA%' and medal = 'Gold'
-- Query 07: Which nation has participated in all of the olympic games?
with max_participated_games as(
select
	count(distinct games) as max
from
	olympics_history
),
countries_num_games as (
select
	team as country,
	count(distinct games) as total_participated_games
from
	olympics_history 
group by country
order by total_participated_games desc
)
select 
	country,
	total_participated_games
from
	max_participated_games join countries_num_games on max_participated_games.max = countries_num_games.total_participated_games

-- Query 08: Identify the sport which was played in all summer olympics.
with all_summer as (
select
	count(distinct games) as total_games
from
	olympics_history
where season = 'Summer'
),
games_per_sport as (
select distinct
	sport,
	count(distinct games) as no_of_games
from
	olympics_history
where season = 'Summer'
group by sport
order by no_of_games desc
)
select
	*
from
	games_per_sport join all_summer on games_per_sport.no_of_games = all_summer.total_games

-- Query 09: Which Sports were just played only once in the olympics?
 with t1 as
          	(select distinct games, sport
          	from olympics_history),
          t2 as
          	(select sport, count(1) as no_of_games
          	from t1
          	group by sport)
select 
	t2.*, t1.games
from 
	t2 join t1 on t1.sport = t2.sport
where t2.no_of_games = 1
order by t1.sport;
-- Query 10: Fetch the top 5 athletes who have won the most gold medals.
select 
	name, 
	team, 
	count(medal) as total_gold_medals
from 
	olympics_history
where 
	medal = 'Gold'
group by 
	name, team
order by 
	total_gold_medals desc
limit 5
-- Query 11: Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select 
	name, 
	team, 
	count(medal) as total_gold_medals
from 
	olympics_history
group by 
	name, team
order by 
	total_gold_medals desc
limit 5
-- Query 12: Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select 
	region, 
	count(medal) as total_medals,
	RANK () OVER (ORDER BY count(medal) desc) AS rnk
from 
	olympics_history_noc_regions inner join  olympics_history using(noc)
where 
	medal not like '%NA%'
group by region
order by total_medals desc
limit 5
-- Query 13: List down total gold, silver and bronze medals won by each country.
select distinct region as country,
   sum(case when medal = 'Gold' then 1 else 0 end) as gold,
   sum(case when medal = 'Silver' then 1 else 0 end) as silver,
   sum(case when medal = 'Bronze' then 1 else 0 end) as bronze
from olympics_history inner join olympics_history_noc_regions using (noc)
group by country
order by gold desc
-- Query 13: List down total gold, silver and bronze medals won by each country.
select games, region as country,
   sum(case when medal = 'Gold' then 1 else 0 end) as gold,
   sum(case when medal = 'Silver' then 1 else 0 end) as silver,
   sum(case when medal = 'Bronze' then 1 else 0 end) as bronze
from olympics_history inner join olympics_history_noc_regions using (noc)
group by games, country
order by games, country
