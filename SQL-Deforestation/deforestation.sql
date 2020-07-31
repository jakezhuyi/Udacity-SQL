-- Steps to Complete
/* Add this line to drop VIEW if it already exists */
DROP VIEW IF EXISTS forestation;
/* Rest of your code follows */
CREATE VIEW forestation AS
SELECT fa.country_code code, fa.country_name country, 
  fa.year "year", fa.forest_area_sqkm forest_area_sqkm,
  la.total_area_sq_mi total_area_sq_mi, 
  r.region region, r.income_group income_group,
  100.0*(fa.forest_area_sqkm / 
  (la.total_area_sq_mi * 2.59)) AS percentage
FROM forest_area fa, land_area la, regions r
WHERE (fa.country_code  = la.country_code AND
  fa.year = la.year AND
  r.country_code = la.country_code);

SELECT * FROM forestation;

-- 1
SELECT *
FROM forest_area
WHERE country_name = 'World';

SELECT *
FROM forest_area
WHERE country_name = 'World'
AND (year = 2016 OR year = 1990);
-- country_code	country_name	year	forest_area_sqkm
-- WLD	        World	        2016	39958245.9
-- WLD	        World	        1990	41282694.9

SELECT  
  curr.forest_area_sqkm - prev.forest_area_sqkm
  AS difference
FROM forest_area AS curr
JOIN forest_area AS prev
  ON  (curr.year = '2016' AND prev.year = '1990'
  AND curr.country_name = 'World' AND prev.country_name = 'World');
-- difference
-- -1324449

SELECT  
  100.0*(curr.forest_area_sqkm - prev.forest_area_sqkm) / 
  prev.forest_area_sqkm AS percentage
FROM forest_area AS curr
JOIN forest_area AS prev
  ON  (curr.year = '2016' AND prev.year = '1990'
  AND curr.country_name = 'World' AND prev.country_name = 'World');
-- percentage
-- -3.20824258980244

SELECT country, (total_area_sq_mi * 2.59) AS total_area_sqkm
FROM forestation
WHERE year = 2016
ORDER BY total_area_sqkm;
-- Peru  1279999.9891

-- 2
SELECT percentage
FROM forestation
WHERE year = 2016
AND country = 'World';
-- 31.3755709643095

SELECT *
FROM forestation
WHERE year = 1990
AND country = 'World';
-- 32.4222035575689

-- https://knowledge.udacity.com/questions/173061
SELECT ROUND(CAST((region_forest_1990/ region_area_1990) * 100 AS NUMERIC), 2) 
  AS forest_percent_1990,
  ROUND(CAST((region_forest_2016 / region_area_2016) * 100 AS NUMERIC), 2) 
  AS forest_percent_2016,
  region  
FROM (SELECT SUM(a.forest_area_sqkm) region_forest_1990,
  SUM(a.total_area_sqkm) region_area_1990, a.region,
  SUM(b.forest_area_sqkm) region_forest_2016,
  SUM(b.total_area_sqkm)  region_area_2016
FROM  forestation a, forestation b
WHERE  a.year = '1990'
AND a.country != 'World'
AND b.year = '2016'
AND b.country != 'World'
AND a.region = b.region
GROUP  BY a.region) region_percent 
ORDER  BY forest_percent_1990 DESC;
-- forest_percent_1990 forest_percent_2016 region
-- 51.03               46.16               Latin America & Caribbean
-- 37.28               38.04               Europe & Central Asia
-- 35.65               36.04               North America
-- 30.67               28.79               Sub-Saharan Africa
-- 25.78               26.36               East Asia & Pacific
-- 16.51               17.51               South Asia
-- 1.78                2.07                Middle East & North Africa

-- 3
SELECT curr.country_name, 
  curr.forest_area_sqkm - prev.forest_area_sqkm AS difference
FROM forest_area AS curr
JOIN forest_area AS prev
  ON  (curr.year = '2016' AND prev.year = '1990')
  AND curr.country_name = prev.country_name
ORDER BY difference DESC;
-- China         527229.062
-- United States 79200

SELECT curr.country_name,
  100.0*(curr.forest_area_sqkm - prev.forest_area_sqkm) / 
  prev.forest_area_sqkm AS percentage
FROM forest_area AS curr
JOIN forest_area AS prev
  ON  (curr.year = '2016' AND prev.year = '1990')
  AND curr.country_name = prev.country_name
ORDER BY percentage DESC;
-- Iceland           213.664588870028
-- French Polynesia  181.818181818182

SELECT curr.country_name, 
  curr.forest_area_sqkm - prev.forest_area_sqkm AS difference
FROM forest_area AS curr
JOIN forest_area AS prev
  ON  (curr.year = '2016' AND prev.year = '1990')
  AND curr.country_name = prev.country_name
ORDER BY difference;
-- Brazil    -541510
-- Indonesia -282193.9844
-- Myanmar   -107234.0039
-- Nigeria   -106506.00098
-- Tanzania  -102320

SELECT curr.country_name,
  100.0*(curr.forest_area_sqkm - prev.forest_area_sqkm) / 
  prev.forest_area_sqkm AS percentage
FROM forest_area AS curr
JOIN forest_area AS prev
  ON  (curr.year = '2016' AND prev.year = '1990')
  AND curr.country_name = prev.country_name
ORDER BY percentage;
-- Togo        -75.4452559270073
-- Nigeria     -61.7999309388418
-- Uganda      -59.1286034729531
-- Mauritania  -46.7469879518072
-- Honduras    -45.0344149459194

-- https://knowledge.udacity.com/questions/206955
SELECT distinct(quartiles), COUNT(country) OVER (PARTITION BY quartiles)
FROM (SELECT country,
  CASE WHEN percentage <= 25 THEN '0-25%'
  WHEN percentage <= 75 AND percentage > 50 THEN '50-75%'
  WHEN percentage <= 50 AND percentage > 25 THEN '25-50%'
  ELSE '75-100%'
END AS quartiles FROM forestation
WHERE percentage IS NOT NULL AND year = 2016) quart;
-- quartiles count
-- 0-25%     85
-- 25-50%    73
-- 50-75%    38
-- 75-100%   9

SELECT country, percentage
FROM forestation
WHERE percentage > 75 AND year = 2016;
-- country               percentage
-- American Samoa        87.5000875000875
-- Micronesia, Fed. Sts. 91.8572390715248
-- Gabon                 90.0376418700565
-- Guyana                83.9014489110682
-- Lao PDR               82.1082317640861
-- Palau                 87.6068085491204
-- Solomon Islands       77.8635177945066
-- Suriname              98.2576939676578
-- Seychelles            88.4111367385789

-- SELECT quartile.ntile, COUNT(ntile)
-- FROM (SELECT country, NTILE(4) OVER
--   (ORDER BY percentage)
--   FROM forestation
--   WHERE year = 2016)
--   AS quartile;
-- ntile count
-- 4     54
-- 1     55
-- 3     54
-- 2     55