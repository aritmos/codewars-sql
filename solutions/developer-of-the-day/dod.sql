WITH date_series AS (
  SELECT
    generate_series(
      '2023-07-01' :: date,
      '2023-09-30' :: date,
      '1 day' :: interval
    ) :: date AS date
),
weekdays_and_dates AS (
  SELECT
    ROW_NUMBER() OVER () - 1 as row_num,
    date,
    weekday
  FROM
    (
      SELECT
        date,
        to_char(date, 'Day') as weekday
      FROM
        date_series
    ) tmp
  WHERE
    TRIM(weekday) NOT IN ('Saturday', 'Sunday')
),
backend_employees_desc_age AS (
  SELECT
    ROW_NUMBER() OVER (
      ORDER BY
        birth_date desc
    ) - 1 as row_num,
    employee_id,
    full_name
  FROM
    (
      SELECT
        *
      FROM
        employees
      WHERE
        team = 'backend'
    ) tmp
),
num_backend_employees AS (
  SELECT
    COUNT(*)
  FROM
    employees
  WHERE
    team = 'backend'
)
SELECT
  wd.date,
  wd.weekday as day_of_week,
  ed.employee_id,
  ed.full_name
FROM
  weekdays_and_dates wd
  JOIN backend_employees_desc_age ed ON (
    wd.row_num % (
      SELECT
        *
      FROM
        num_backend_employees
    ) = ed.row_num
  )
ORDER BY
  wd.date;
