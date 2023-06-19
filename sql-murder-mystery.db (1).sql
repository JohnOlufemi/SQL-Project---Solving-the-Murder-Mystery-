
--OVERVIEW:

--A crime has taken place and the detective needs your help. 
--The detective gave you the crime scene report, but you somehow lost it. 
--You vaguely remember that the crime was a murder that occurred sometime on Jan.15, 2018 and that it took place in SQL City. 
--Start by retrieving the corresponding crime scene report from the police department’s database. 
--Figure out who committed the crime with the details you remembered above.




--Step 1:Retrived the crime scene report from the police department database
Select *
from crime_scene_report

--Step 2: Filtered the table with the detective brief, the brief identified that the crime was a murder, occured on Jan. 15 2018, took place in SQL City
SELECT *
From crime_scene_report
WHERE type = "murder" and date = 20180115 AND city = "SQL City"

-- From the query the description column: Securtiy footage shows 2 witnessess, the first lives on "Northwestern Dr" and the second witness, named Annabel, lives somewhere on "Franklin Ave”

--Step 3: This information was used to find the ID and name of the first witness. Done by querying the Person table and filtering it with the address “Northwestern Dr". Taking into account that the witness lives in the last house
SELECt name, id, address_street_name
FROM person
where address_street_name = "Northwestern Dr"
ORDER BY address_number DESC
limit 1

--The first witness is Morty Schapiro, with id 14887

--Step 4: The second witness ID number will be retrieved using name and address. This is done by querying the Person table and filtering it with the witness’s name and address: “Annabel and Franklin Ave".
SELECT name, id, address_street_name
FROM person
WHERE name LIKE '%Annabel%' AND address_street_name = 'Franklin Ave'

--The name of the second witness is Annabel Miller with ID number 16371

--Step 5: After retrieving the ID of the two witnesses, I checked the database schema, which showed that the person and interview tables has primary and foreign key. The person table has the primary key (id), and the interview table has the foreign key (person_id). This was used to join both tables to check the details of each witness transcripts. 
SELECT person.id, person.name, interview.transcript
FROM person
Join interview
ON person.id = interview.person_id
WHERE person.id = 16371 OR person.id = 14887

--The First Witness- Morty Schapiro transcript: heard a gunshot and then saw a man run out. He had a ""Get Fit Now Gym"" bag. The membership number on the bag started with ""48Z"". Only gold members have those bags. The man got into a car with a plate that included ""H42W""
--The Second Witness- Annabel Miller transcript: saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.
--The first witness (Morty Schapiro's) testimony revealed that the killer is a man and a gym member

--Step 6: Wrote a query to check the get_fit_now_member table and filtered the table based on what the first witness (Morty Schapiro) mentioned-Membership number with”48Z on a bag which is identified with Gold- Membership status
SELECT *
FROM get_fit_now_member
WHERE get_fit_now_member.id  LIKE  '48Z%' AND membership_status = 'gold'

--Result shows that only two members (Joe Germuska and Jeremy Bowers) have gold membership status, and their Membership_id are as follows (48Z7A and 48Z55) with 67318, 28819 as their person_id is respectively

-- Step 7: Based on the second witness (Annabel Miller’s) testimony - (She mentioned that she was working out on the 9th of January). I wrote a query to check the get_fit_now_check_in table and filtered it with the 2 membership id from the first witness transcript (48Z7A and 48Z55)
SELECT *
FROM get_fit_now_check_in
WHERE check_in_date = '20180109' AND membership_id in ('48Z7A' , '48Z55')

--The query result shows that the two members with gold membership status and Membership_id (48Z7A and 48Z55) both checked in on the 9th of January 2018.
--From the findings the crime was committed by Joe Germuska or Jeremy Bowers.
-- Morty Schapiro- mentioned that the man got into a car with a plate that included H42W

--Step 8: To identify the main suspect, I joined the person table and driver license table, and filtered it with their person_id to find out whose car was registered with the plate ‘H42W’
SELECT person.name,drivers_license.plate_number,drivers_license.gender,person.address_number,person.address_street_name,person.ssn
FROM person
JOIN drivers_license
ON drivers_license.id = person.license_id
WHERE person.id IN (67318,28819)

--From the Query result, it shows that Jeremy bowers has a car with a plate_number H42W as mentioned by the first witness and his gender reveal that he is male and reside at 530, Washington PI, Apt 3A

--Step 9: Jeremy Bowers is the main suspect based on the two-witness description. However, to confirm he was the one who committed the murder, I went further to check the interview table for his transcript using his person_id (67318)
SELECT *
FROM interview 
WHERE person_id = '67318'

--The transcript result set shows the suspect Jeremy Bowers- mentioned this "I was hired by a woman with a lot of money. I don't know her name, but I know she's around 5'5"" (65") or 5'7"" (67”). She has red hair, and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.”

--Step 10: Step 10:Now, we can see that Jeremy Bowers is the one who committed the murdered, but he was hired by a woman, and he provided information about the main culprit. This information was used in writing a query to retrieve the name of the woman who hired him.
SELECT person.name, person. address_number, person. address_street_name, person.ssn from person
JOIN drivers_license
ON person.license_id = drivers_license.id
JOIN facebook_event_checkin
ON person.id=facebook_event_checkin.person_id
WHERE facebook_event_checkin.event_name is 'SQL Symphony Concert' AND facebook_event_checkin.date LIKE '%201712%' 
	AND  drivers_license.car_make is 'Tesla'AND drivers_license.car_model is 'Model S'
	AND gender is 'female' AND drivers_license.height BETWEEN 65 and 67 AND   drivers_license.hair_color is 'red'
GROUP by person.name
HAVING count(*) == 3

--Summary:The result shows that Miranda Priestly who lives in 1883, Golden Ave with the Ssn:987756388 was the woman who hired Jeremy Bower to commit the murder
