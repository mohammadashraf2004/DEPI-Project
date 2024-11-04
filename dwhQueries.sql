-- Total Number of Feedbacks per User
SELECT 
    u.userid,
    u.profilename,
    COUNT(f.feedback_id) AS total_feedbacks
FROM 
    FeedbackFact f
JOIN 
    users u ON f.user_id = u.userid
GROUP BY 
    u.userid, u.profilename
ORDER BY 
    total_feedbacks DESC;

-- Average Score by Year and Month
SELECT 
    t.year,
    t.month,
    AVG(f.score) AS avg_score
FROM 
    FeedbackFact f
JOIN 
    TimeDimension t ON f.time_id = t.time_id
GROUP BY 
    t.year, t.month
ORDER BY 
    t.year, t.month;

--  Most Helpful Feedback by User
SELECT 
    u.userid,
    u.profilename,
    f.feedback_id,
    f.summary,
    (f.helpfulness_numerator * 1.0 / f.helpfulness_denominator) AS helpfulness_score
FROM 
    FeedbackFact f
JOIN 
    users u ON f.user_id = u.userid
WHERE 
    f.helpfulness_denominator > 0
ORDER BY 
    helpfulness_score DESC;

-- Feedback Count by Day of the Week
SELECT 
    DATENAME(WEEKDAY, t.feedback_date) AS day_of_week,
    COUNT(f.feedback_id) AS feedback_count
FROM 
    FeedbackFact f
JOIN 
    TimeDimension t ON f.time_id = t.time_id
GROUP BY 
    DATENAME(WEEKDAY, t.feedback_date)
ORDER BY 
    feedback_count DESC;

	
-- Feedback Distribution by Score Over Time
SELECT 
    t.year,
    t.month,
    f.score,
    COUNT(f.feedback_id) AS feedback_count
FROM 
    FeedbackFact f
JOIN 
    TimeDimension t ON f.time_id = t.time_id
GROUP BY 
    t.year, t.month, f.score
ORDER BY 
    t.year, t.month, f.score;


-- Top 5 Users with the Highest Average Feedback Score
SELECT top(5)
    u.userid,
    u.profilename,
    AVG(f.score) AS avg_score
FROM 
    FeedbackFact f
JOIN 
    users u ON f.user_id = u.userid
GROUP BY 
    u.userid, u.profilename
ORDER BY 
    avg_score DESC;

--Feedback Count per Product per Year
SELECT 
    f.product_id,
    t.year,
    COUNT(f.feedback_id) AS feedback_count
FROM 
    FeedbackFact f
JOIN 
    TimeDimension t ON f.time_id = t.time_id
GROUP BY 
    f.product_id, t.year
ORDER BY 
    t.year, feedback_count DESC;

