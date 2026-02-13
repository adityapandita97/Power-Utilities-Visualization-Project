-- SQL queries to validate data integrity
SELECT COUNT(*) FROM interval_reads_2021;
SELECT MIN(readdatetime), MAX(readdatetime) FROM interval_reads_2021;
