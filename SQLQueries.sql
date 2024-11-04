--This query retrieves all feedback records along with the associated user's profile name.
SELECT f.FeedbackId, f.ProductId, u.ProfileName, f.Score, f.Summary
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId;

--This query summarizes the feedback for each product.
SELECT ProductId, COUNT(FeedbackId) AS TotalFeedbacks, AVG(Score) AS AverageScore
FROM Feedback
GROUP BY ProductId;

--This query calculates the helpfulness ratio for each feedback entry.
SELECT FeedbackId, 
       (HelpfulnessNumerator * 1.0 / NULLIF(HelpfulnessDenominator, 0)) AS HelpfulnessRatio
FROM Feedback;

--This query retrieves the most recent 10 feedback entries
SELECT TOP 10 FeedbackId, ProductId, UserId, Score, Summary, Time
FROM Feedback
ORDER BY Time DESC;

--This query finds feedback entries with scores lower than 3.
SELECT f.FeedbackId, f.ProductId, u.ProfileName, f.Score, f.Summary
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
WHERE f.Score < 3;

--This query identifies the top 5 products based on average helpfulness ratio.
SELECT TOP 5 ProductId, 
       AVG(CASE WHEN HelpfulnessDenominator > 0 THEN (HelpfulnessNumerator * 1.0 / HelpfulnessDenominator) ELSE 0 END) AS AvgHelpfulnessRatio
FROM Feedback
GROUP BY ProductId
ORDER BY AvgHelpfulnessRatio DESC;

--This query retrieves the top 10 users who provided the most feedback.
SELECT TOP 10 u.ProfileName, COUNT(f.FeedbackId) AS TotalFeedbacks
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
GROUP BY u.ProfileName
ORDER BY TotalFeedbacks DESC;

-- This query calculates the average score for users who have provided more than 5 feedback entries.
SELECT u.ProfileName, AVG(f.Score) AS AverageScore, COUNT(f.FeedbackId) AS TotalFeedbacks
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
GROUP BY u.ProfileName
HAVING COUNT(f.FeedbackId) > 5
ORDER BY AverageScore DESC;

--This query summarizes feedback by month and year.
SELECT YEAR(Time) AS Year, 
       MONTH(Time) AS Month, 
       COUNT(FeedbackId) AS TotalFeedbacks
FROM Feedback
GROUP BY YEAR(Time), MONTH(Time)
ORDER BY Year DESC, Month DESC;

--This query retrieves the top 10 feedback entries with the highest helpfulness ratios.
SELECT f.FeedbackId, f.ProductId, u.ProfileName, 
       (f.HelpfulnessNumerator * 1.0 / NULLIF(f.HelpfulnessDenominator, 0)) AS HelpfulnessRatio, 
       f.Score, f.Summary
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
WHERE f.HelpfulnessDenominator > 0
ORDER BY HelpfulnessRatio DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--This query identifies the top 5 products with more than 10 feedback entries and retrieves their average scores.
SELECT TOP 5 ProductId, 
       AVG(Score) AS AverageScore, 
       COUNT(FeedbackId) AS TotalFeedbacks
FROM Feedback
GROUP BY ProductId
HAVING COUNT(FeedbackId) > 10
ORDER BY AverageScore ASC;

--This query retrieves the average score of feedback by each user for each product
SELECT u.ProfileName, f.ProductId, AVG(f.Score) AS AverageScore, COUNT(f.FeedbackId) AS TotalFeedbacks
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
GROUP BY u.ProfileName, f.ProductId
HAVING COUNT(f.FeedbackId) > 3
ORDER BY TotalFeedbacks DESC;

--This query calculates the average helpfulness ratio for each user.
SELECT u.ProfileName, 
       AVG(CASE WHEN f.HelpfulnessDenominator > 0 THEN (f.HelpfulnessNumerator * 1.0 / f.HelpfulnessDenominator) ELSE 0 END) AS AvgHelpfulnessRatio
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
GROUP BY u.ProfileName
ORDER BY AvgHelpfulnessRatio DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--This query identifies the top 5 products with the highest percentage of positive feedback (feedback scores of 4 or higher).
SELECT ProductId, 
       SUM(CASE WHEN Score >= 4 THEN 1 ELSE 0 END) AS PositiveFeedbacks,
       COUNT(FeedbackId) AS TotalFeedbacks,
       (SUM(CASE WHEN Score >= 4 THEN 1 ELSE 0 END) * 1.0 / COUNT(FeedbackId)) AS PositiveFeedbackPercentage
FROM Feedback
GROUP BY ProductId
ORDER BY PositiveFeedbackPercentage DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--Tracks feedback with the greatest improvement in helpfulness over time.
WITH FeedbackRanking AS (
  SELECT FeedbackId, ProductId, Time, 
         LAG(HelpfulnessNumerator, 1) OVER (PARTITION BY ProductId ORDER BY Time) AS PrevNumerator, 
         LAG(HelpfulnessDenominator, 1) OVER (PARTITION BY ProductId ORDER BY Time) AS PrevDenominator, 
         HelpfulnessNumerator, HelpfulnessDenominator
  FROM Feedback
)
SELECT TOP 10 FeedbackId, ProductId, Time, 
       (HelpfulnessNumerator * 1.0 / NULLIF(HelpfulnessDenominator, 0)) AS CurrentHelpfulnessRatio, 
       (PrevNumerator * 1.0 / NULLIF(PrevDenominator, 0)) AS PrevHelpfulnessRatio, 
       ((HelpfulnessNumerator * 1.0 / NULLIF(HelpfulnessDenominator, 0)) - (PrevNumerator * 1.0 / NULLIF(PrevDenominator, 0))) AS Improvement
FROM FeedbackRanking
WHERE PrevDenominator IS NOT NULL
ORDER BY Improvement DESC;

--Provides a summary of feedback by week, including average scores and total feedback count.
SELECT YEAR(Time) AS Year, 
       DATEPART(WEEK, Time) AS Week, 
       AVG(Score) AS AverageScore, 
       COUNT(FeedbackId) AS TotalFeedbacks
FROM Feedback
GROUP BY YEAR(Time), DATEPART(WEEK, Time)
ORDER BY Year DESC, Week DESC;

--Identifies the top 10 users who have given the highest percentage of high-score feedback (scores of 4 or higher).
SELECT TOP 10 u.ProfileName, 
       COUNT(f.FeedbackId) AS TotalFeedbacks, 
       SUM(CASE WHEN f.Score >= 4 THEN 1 ELSE 0 END) AS HighScoreFeedbacks,
       (SUM(CASE WHEN f.Score >= 4 THEN 1 ELSE 0 END) * 1.0 / COUNT(f.FeedbackId)) AS HighScorePercentage
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
GROUP BY u.ProfileName
HAVING COUNT(f.FeedbackId) > 5  
ORDER BY HighScorePercentage DESC;

 --Retrieves feedback entries submitted on weekends (Sunday and Saturday).
SELECT FeedbackId, ProductId, UserId, Score, Time
FROM Feedback
WHERE DATEPART(WEEKDAY, Time) IN (1, 7)  
ORDER BY Time DESC;

-- Identifies users whose feedback helpfulness ratio exceeds the average for the product.
WITH ProductAvgHelpfulness AS (
  SELECT ProductId, 
         AVG(CASE WHEN HelpfulnessDenominator > 0 THEN (HelpfulnessNumerator * 1.0 / HelpfulnessDenominator) ELSE 0 END) AS AvgHelpfulnessRatio
  FROM Feedback
  GROUP BY ProductId
)
SELECT u.ProfileName, f.ProductId, f.HelpfulnessNumerator, f.HelpfulnessDenominator, 
       (f.HelpfulnessNumerator * 1.0 / NULLIF(f.HelpfulnessDenominator, 0)) AS UserHelpfulnessRatio, 
       p.AvgHelpfulnessRatio
FROM Feedback f
JOIN Users u ON f.UserId = u.UserId
JOIN ProductAvgHelpfulness p ON f.ProductId = p.ProductId
WHERE (f.HelpfulnessNumerator * 1.0 / NULLIF(f.HelpfulnessDenominator, 0)) > p.AvgHelpfulnessRatio
ORDER BY UserHelpfulnessRatio DESC;

-- Finds the top 5 products based on the number of feedback entries
SELECT ProductId, 
       COUNT(FeedbackId) AS FeedbackCount
FROM Feedback
GROUP BY ProductId
ORDER BY FeedbackCount DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY; 

--Finds the top 5 products with the highest helpfulness ratio, filtering out products with fewer than 5 feedback entries.
SELECT ProductId, 
       (SUM(HelpfulnessNumerator) * 1.0 / NULLIF(SUM(HelpfulnessDenominator), 0)) AS HelpfulnessRatio
FROM Feedback
GROUP BY ProductId
HAVING COUNT(FeedbackId) > 5  
ORDER BY HelpfulnessRatio DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY; 

--Feedback Helpfulness Improvement Over Time (with Pagination)
WITH FeedbackRanking AS (
  SELECT FeedbackId, ProductId, Time, 
         LAG(HelpfulnessNumerator, 1) OVER (PARTITION BY ProductId ORDER BY Time) AS PrevNumerator, 
         LAG(HelpfulnessDenominator, 1) OVER (PARTITION BY ProductId ORDER BY Time) AS PrevDenominator, 
         HelpfulnessNumerator, HelpfulnessDenominator
  FROM Feedback
)
SELECT FeedbackId, ProductId, Time, 
       (HelpfulnessNumerator * 1.0 / NULLIF(HelpfulnessDenominator, 0)) AS CurrentHelpfulnessRatio, 
       (PrevNumerator * 1.0 / NULLIF(PrevDenominator, 0)) AS PrevHelpfulnessRatio, 
       ((HelpfulnessNumerator * 1.0 / NULLIF(HelpfulnessDenominator, 0)) - (PrevNumerator * 1.0 / NULLIF(PrevDenominator, 0))) AS Improvement
FROM FeedbackRanking
WHERE PrevDenominator IS NOT NULL
ORDER BY Improvement DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;  


