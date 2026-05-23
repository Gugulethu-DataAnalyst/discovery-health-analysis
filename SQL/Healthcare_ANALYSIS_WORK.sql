use discoverymember_data;

/*Displaying all fields and 10 records from the member_vitality table*/
select * from member_vitality;

/*creating basic  statistics for our experimentation*/
/*Displaying total value of distict members in the data table*/
SELECT COUNT(DISTINCT MEMBER_ID) AS totalMmbers from member_vitality;

/*Total claims recorded in the data table*/
SELECT COUNT(DISTINCT CLAIM_ID) AS TotalClaims from member_vitality;

/*Total vitality records(assumming steps or gym visits represents engagement)*/
SELECT COUNT(*) AS TotalVitality_Entries
FROM member_vitality
WHERE STEPS IS NOT NULL OR GYM_VISITS IS NOT NULL;

/*Gender distribution, age groups, region breakdown*/
/*Gender distribution*/
SELECT GENDER, COUNT(*) AS Count_Gender
FROM member_vitality 
GROUP BY GENDER;

/*Select case for age distribution for our experiment*/
SELECT
  CASE
    WHEN AGE BETWEEN 18 AND 29 THEN '18-29'
    WHEN AGE BETWEEN 30 AND 44 THEN '30-44'
    WHEN AGE BETWEEN 45 AND 59 THEN '45-59'
    WHEN AGE >= 60 THEN '60+'
    ELSE 'Unknown'
  END AS Age_Group,
  COUNT(*) AS MemberCount 
FROM member_vitality
GROUP BY Age_Group;
/*----------------------------------SAFETY OFF------------------------------------------------*/
SET SQL_SAFE_UPDATES = 1;
/*----------------------------------------------------------------------------------*/

/*fIxing data type*/
UPDATE member_vitality
SET REGION = 'Western Cape'
WHERE REGION IN ('WESTERN CAPE','W CAPE');

UPDATE member_vitality
SET REGION = 'Eastern Cape'
WHERE REGION IN ('EASTERN CAPE');

UPDATE member_vitality
SET REGION = 'Gauteng'
WHERE REGION IN ('GAUTENG', 'GAUTEN');

UPDATE member_vitality
SET REGION = 'Unknown'
WHERE REGION IN ('UNKNOWN');

/*B. 
counting members grouped by region */
SELECT REGION, COUNT(*) AS MemberByRegion
FROM member_vitality
group by REGION;

/*Total amount claims grouped by region*/
SELECT REGION, count(CLAIM_ID) as TOTALCLAIMS, SUM(AMOUNT_CLAIMED) AS TOTAL_AMOUNT
FROM member_vitality
GROUP BY REGION; 

/*Lets check claim data vs their wellness activities*/
SELECT REGION, COUNT(CLAIM_ID) AS TOTALCLAIMS, SUM(STEPS) AS TOTALSTEPS, SUM(GYM_VISITS) AS TOTAL_GYM_VISITS
FROM member_vitality
GROUP BY REGION;

/*C.
 Average steps, gym visits and pointed earned.*/
 SELECT 
 ROUND(AVG(STEPS),0) AS AvgSteps,
 ROUND(AVG(GYM_VISITS), 0) AS AvgGym_visits
 FROM member_vitality;
    

 /*segmenting member by gender and plan type*/
 /*GROUP BY PLAN TYPE, AND GENDER*/
 SELECT GENDER, PLAN_TYPE, COUNT(*) AS MEMBERCOUNT
 FROM member_vitality
 group by GENDER, PLAN_TYPE;
 
 /*count and Group by chronic condition*/
 SELECT CHRONIC_CONDITION, COUNT(*) AS TotalChronicCount
 FROM member_vitality
 GROUP BY CHRONIC_CONDITION
 ORDER BY TotalChronicCount DESC;
 
 /*analysis of total diagnoses code by chronic condition*/
 SELECT DIAGNOSIS_CODE, COUNT(DIAGNOSIS_CODE) AS TOTAL_DIAGNOSIS_CODE
 FROM member_vitality
 GROUP BY DIAGNOSIS_CODE;
 
 /*==========================ENDED HERE(2025/07/22)===================================*/
 
 /*IDENTIFYING TOP 10 POINTS EARNED BY MBEMBER*/
 SELECT MEMBER_ID, FIRSTNAME, SURNAME, POINTS_EARNED
 FROM member_vitality
 order by POINTS_EARNED DESC
 LIMIT 10;
 
 /*FINDING CLAIMS AND AMOUNT PER REGION*/
 SELECT REGION, 
  SUM(AMOUNT_CLAIMED) AS Total_Amount_Claimed, 
  SUM(AMOUNT_PAID) AS Total_Amount_Paid
FROM member_vitality
GROUP BY REGION
ORDER BY REGION;
 
 /*finding max amount_claimed grouped by member id, name and surname*/
 SELECT MEMBER_ID,
 MAX(FIRSTNAME) AS Firstname,
 max(SURNAME) as surname,
 ROUND(MAX(AMOUNT_CLAIMED),0) AS MAXClaimed_Amount
 FROM member_vitality
 group by member_ID
 order by MAXClaimed_Amount desc
 limit 5;
 
 /*Total diagnosis made by providers*/
 SELECT PROVIDER_TYPE,
 COUNT(DIAGNOSIS_CODE) AS TOTAL_DIAGNOSIS_BY_Provider
 from member_vitality
 group by provider_type;
 
 SELECT DIAGNOSIS_CODE, COUNT(*) AS ClaimCount
FROM MEMBER_VITALITY
WHERE DIAGNOSIS_CODE IS NOT NULL
GROUP BY DIAGNOSIS_CODE
ORDER BY ClaimCount DESC
LIMIT 10;

/*====================================================================
========================================================
=============================*/
/*Comparing activity vs points*/
SELECT 
ROUND(AVG(steps), 0) as AVGsteps,
ROUND(AVG(POINTS_EARNED),0) AVGpoints
from member_vitality
where steps is not null;
/*If member hits 11147 steps they are to recieve 73 points for activity initiative*/

/*Lets check the gym visits vs points earned*/
SELECT 
ROUND(AVG(GYM_VISITS),0) AS AVGgym,
ROUND(AVG(POINTS_EARNED),0) AS AVGpoints
from member_vitality
where gym_visits is not null;

/*====================================================================
========================================================
=============================*/
/*Time based engagement - line graph*/
SELECT
WEEK_START,
ROUND(AVG(STEPS),0) AS AVGsteps,
ROUND(AVG(GYM_VISITS),0) AS AVGgym_visit,
ROUND(AVG(POINTS_EARNED),0) AS AVGpoints
from member_vitality
group by week_start
order by week_start;

/*====================================================================
========================================================
=============================*/
/*HIGH RISK MEMBERS*/
SELECT
MEMBER_ID, FIRSTNAME, SURNAME, SUM(AMOUNT_CLAIMED) AS TOTALClaimed, CHRONIC_CONDITION
FROM member_vitality
group by MEMBER_ID, FIRSTNAME,SURNAME, CHRONIC_CONDITION
HAVING TOTALClaimed > 500 and CHRONIC_CONDITION = 1
ORDER BY TOTALClaimed DESC;


/*====================================================================
========================================================
=============================*/

/* Active vs Inactive MEMBERS */
SELECT
  CASE
    WHEN STEPS > 0 OR GYM_VISITS > 0 THEN 'Active'
    ELSE 'Inactive'
  END AS ENGAGEMENTSTATUS,
  ROUND(AVG(AMOUNT_CLAIMED), 0) AS AVGclaimed
FROM member_vitality
GROUP BY ENGAGEMENTSTATUS;

/*-======================================================*/
SELECT
CASE
WHEN STEPS > 0 OR GYM_VISITS < 0 THEN 'Active'
else 'Inactive'
END AS ENGAGEMENTSTATUS,
ROUND(AVG(AMOUNT_CLAIMED),0) AS AVGclaimed
from member_vitality
group by ENGAGEMENTSTATUS;

/*====================================================================
=======================================================
==============================
====================
=========*/
/*Caims vs Engageent Correlation*/
SELECT member_id,
SUM(AMOUNT_CLAIMED) AS Total_Claims,
SUM(STEPS) AS Total_Steps,
SUM(GYM_VISITS) AS Total_Gym_Visits
FROM member_vitality
GROUP BY member_ID;

/*Monthly Claims Trend*/
Select 
MONTH(CLAIM_DATE) AS ClaimMonth,
SUM(AMOUNT_CLAIMED) AS MonthlyClaimedTotal
FROM member_vitality
GROUP BY ClaimMonth
ORDER BY ClaimMonth;

/*5. PLAN TYPE VS cLAIM FREQUENCY*/
SELECT PLAN_TYPE,
COUNT(DISTINCT MEMBER_ID) AS MemberCount,
COUNT(CLAIM_ID) AS TotalClaims,
Round(count(CLAIM_ID) * 1.0 / COUNT(DISTINCT MEMBER_ID),2) AS AVG_ClaimPer_Member
FROM member_vitality
GROUP BY PLAN_TYPE;

/*Wellness engagement score*/
SELECT
MEMBER_ID,
(SUM(STEPS)/1000 + SUM(GYM_VISITS)*10) AS EngagementScore
FROM member_vitality
GROUP BY MEMBER_ID;

SELECT
 MEMBER_ID, 
 GENDER, 
 AGE, 
 PLAN_TYPE, 
 REGION, 
 CAST(AMOUNT_CLAIMED AS DECIMAL(10,2)) AS AMOUNT_CLAIMED_NUMERIC,
 CAST(AMOUNT_PAID AS DECIMAL(10,2)) AS AMOUNT_PAID_NUMERIC
FROM member_vitality
GROUP BY MEMBER_ID;