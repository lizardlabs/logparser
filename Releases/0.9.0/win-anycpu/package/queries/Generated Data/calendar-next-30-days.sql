-- title: Calendar for the next 30 days
-- description: Use the Dates provider to build a localized planning calendar.
DROP TABLE IF EXISTS temp.calendar_source;

CREATE VIRTUAL TABLE temp.calendar_source
USING ParsingModule('2000-01-01,2100-12-31', '-i:Dates');

SELECT Date,
       DayOfWeekName,
       MonthName,
       WeekOfYearISO,
       CASE WHEN strftime('%w', Date) IN ('0', '6') THEN 'Weekend' ELSE 'Weekday' END AS DayType
FROM calendar_source
WHERE date(Date) BETWEEN date('now') AND date('now', '+29 days')
ORDER BY Date;
