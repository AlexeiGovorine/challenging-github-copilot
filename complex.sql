WITH WinePerformance AS (
    SELECT
        name,
        region,
        variety,
        CAST(substr(name, length(name) - 3, 4) AS INTEGER) AS wine_year,
        rating,
        AVG(rating) OVER (
            PARTITION BY region, variety
            ORDER BY CAST(substr(name, length(name) - 3, 4) AS INTEGER)
            ROWS BETWEEN 600 PRECEDING AND CURRENT ROW
        ) AS rolling_avg_rating
    FROM wines
    WHERE region <> ''
)
SELECT
    name, region, variety, wine_year, rating, rolling_avg_rating,
    ROUND(rating * 1000 / (rolling_avg_rating + 1), 2) AS performance_ratio,
    CASE
        WHEN rating > rolling_avg_rating THEN 'Above Rolling Avg'
        WHEN rating = rolling_avg_rating THEN 'Equal to Rolling Avg'
        ELSE 'Below Rolling Avg'
    END AS performance_trend,
    CASE
        WHEN rating < 50 THEN 'Low Rating'
        WHEN rating BETWEEN 50 AND 75 THEN 'Medium Rating'
        ELSE 'High Rating'
    END AS rating_category
FROM WinePerformance
ORDER BY region, variety, wine_year DESC, LENGTH(name) DESC
LIMIT 50;
