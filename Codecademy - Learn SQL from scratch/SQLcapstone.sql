SELECT MIN(subscription_start),
			MAX(subscription_start),
      MIN(subscription_end),
     	MAX(subscription_end),
      COUNT(DISTINCT id)
FROM subscriptions;

SELECT DISTINCT segment
FROM subscriptions;

WITH months AS
(SELECT '2017-01-01' as first_day,
				'2017-01-31' as last_day
 UNION 
 
 SELECT '2017-02-01' as first_day,
 			 '2017-02-28' as last_day
 
 UNION 
 
 SELECT '2017-03-01' as first_day,
 			 '2017-03-31' as last_day
 
 FROM subscriptions),
 
 cross_join AS
 (SELECT *
  FROM subscriptions
  CROSS JOIN months),
  
 status AS
 (SELECT id, first_day AS month,
 
  CASE
  	WHEN
 			subscription_start<first_day
  		AND (subscription_end IS NULL OR subscription_end>first_day)
  	THEN 1
  	ELSE 0
  END
  AS 'is_active',
  
  CASE
  	WHEN
  		subscription_end BETWEEN first_day and last_day
  	THEN 1
  	ELSE 0
  END
  AS 'is_canceled'
  
  FROM cross_join),
  
  status_aggregate AS
  (SELECT
  SUM(is_active) as 'sum_active',
  SUM(is_canceled) as 'sum_canceled',
  month
  FROM status
  GROUP BY month)
  
  SELECT 
  month, 1.0 * sum_canceled / sum_active AS churn_rate
  FROM status_aggregate;                              

WITH months AS
(SELECT '2017-01-01' as first_day,
				'2017-01-31' as last_day
 UNION 
 
 SELECT '2017-02-01' as first_day,
 			 '2017-02-28' as last_day
 
 UNION 
 
 SELECT '2017-03-01' as first_day,
 			 '2017-03-31' as last_day
 
 FROM subscriptions),
 
 cross_join AS
 (SELECT *
  FROM subscriptions
  CROSS JOIN months),
  
 status AS
 (SELECT id, first_day AS month,
 
  CASE
  	WHEN segment = '87'
  	AND subscription_start < first_day
  	AND (subscription_end > first_day
  	OR subscription_end IS NULL)
  THEN 1
  ELSE 0
  END
  AS 'is_active_87',
 
  CASE
  	WHEN segment = '30'
  	AND subscription_start < first_day
  	AND (subscription_end > first_day
    OR subscription_end IS NULL)
  THEN 1
  ELSE 0
  END
  AS 'is_active_30',
  
  CASE
  	WHEN segment = '87'
  	AND subscription_end BETWEEN first_day AND last_day
  THEN 1
  ELSE 0
  END                                 
  AS 'is_canceled_87',
  
  CASE
    WHEN segment = '30'
    AND subscription_end BETWEEN
    first_day AND last_day                            
  THEN 1
  ELSE 0
  END                                 
  AS 'is_canceled_30'
         
 FROM cross_join),
 
 status_aggregate AS
 (SELECT month, 
 		SUM(is_active_87) AS 'sum_active_87',
 		SUM(is_active_30) AS 'sum_active_30',
 		SUM(is_canceled_87) AS 'sum_canceled_87',
 		SUM(is_canceled_30) AS 'sum_canceled_30'
  FROM status
 GROUP BY month)

SELECT
month, 1.0 * sum_canceled_87 / sum_active_87 AS 'churn_rate_87', 
1.0 * sum_canceled_30 / sum_active_30
AS 'churn_rate_30'
FROM status_aggregate;



  
  
 
 
 
 

 