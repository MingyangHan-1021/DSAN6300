-- Q1: Find maximal departure delay in minutes for each airline. Sort results from smallest to largest maximum delay. Output airline names and values of the delay.
select L_AIRLINE_ID.Name, max(al_perf.DepDelayMinutes) as MaxDepDelay
from al_perf
join L_AIRLINE_ID on al_perf.dot_id_reporting_airline = L_AIRLINE_ID.ID
group by  L_AIRLINE_ID.Name
order by MaxDepDelay asc;

-- 15 rows returned

-- Q2: Find maximal early departures in minutes for each airline. Sort results from largest to smallest. Output airline names.
select
    L_AIRLINE_ID.NAME as Airline_Name,
    max(-al_perf.DepDelay)as Max_Early_Departure
from al_perf
join L_AIRLINE_ID
    on al_perf.dot_id_reporting_airline = L_AIRLINE_ID.ID
where al_perf.DepDelay < 0
group by L_AIRLINE_ID.NAME
order by Max_Early_Departure desc;

-- 15 rows returned 


-- Q3: Rank days of the week by the number of flights performed by all airlines on that day (1 is the busiest). Output the day of the week names, number of flights and ranks in the rank increasing order.
select 
	rank() over (order by count(al_perf.DayOfWeek) desc) as rank_of_day,
	L_WEEKDAYS.Day as Day_Name,
	count(al_perf.DayOfWeek) AS Number_of_flights
from al_perf 
join L_WEEKDAYS 
on al_perf.DayOfWeek = L_WEEKDAYS.Code
group by L_WEEKDAYS.Day
order by Number_of_flights desc;
-- 7 rows returned 

-- Q4: Find the airport that has the highest average departure delay among all airports. Consider 0 minutes delay for flights that departed early. Output one line of results: the airport name, code, and average delay.
with avg_delay as (
select
    al_perf.Origin as airport_code,
    avg(al_perf.DepDelayMinutes) as avg_departure_delay
    from al_perf
    group by airport_code
)
select Name,airport_code,avg_departure_delay
from avg_delay
join L_AIRPORT on avg_delay.airport_code = L_AIRPORT.code
where avg_departure_delay = (Select MAX(avg_departure_delay) from avg_delay);
-- 1 rows returned 

-- Q5: For each airline find an airport where it has the highest average departure delay. Output an airline name, a name of the airport that has the highest average delay, and the value of that average delay.
with avgdelay as (
    select 
        dot_id_reporting_airline,
        originAirportID,
        avg(DepDelayMinutes) as avg_departure_delay
    from al_perf
    group by dot_id_reporting_airline, originAirportID
),

max_delay_airline as (
    select 
        dot_id_reporting_airline,
        max(avg_departure_delay) as max_delay_dep
    from avgdelay
    group by dot_id_reporting_airline
)

select
    L_AIRLINE_ID.Name as airline_name,
    L_AIRPORT_ID.Name as airport_name,
    avgdelay.avg_departure_delay
from avgdelay
join max_delay_airline
    on avgdelay.dot_id_reporting_airline = max_delay_airline.dot_id_reporting_airline
    and avgdelay.avg_departure_delay = max_delay_airline.max_delay_dep
join L_AIRLINE_ID
    on avgdelay.dot_id_reporting_airline = L_AIRLINE_ID.ID
join L_AIRPORT_ID
    on avgdelay.originAirportID = L_AIRPORT_ID.ID
order by airline_name;
-- 15 rows returned





-- Q6A: Check if your dataset has any canceled flights.
select
    count(*) as num_canceled_flights
from al_perf
where Cancelled = 1;
-- 7058 rows returned 

-- Q6B: If it does, what was the most frequent reason for each departure airport? Output airport name, the most frequent reason, and the number of cancelations for that reason.
-- Q7 :Build a report that for each day output average number of flights over the preceding 3 days.
With num_flights AS (
	select DATE(FlightDate) AS date_flight, COUNT(*) as flights
	from al_perf
	group by date_flight
)
Select date_flight, 
	   AVG(flights) OVER (order by date_flight ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING)
From num_flights
where date_flight is not null;
-- 30 rows returned

