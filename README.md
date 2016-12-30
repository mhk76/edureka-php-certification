# Edureka PHP Certification project (with Angular and without CakePHP)
Changes compared to the spec:
- empoyees table: changed create_date to TIMESTAMP (from VARCHAR) and basic_pay to FLOAT (from VARCHAR)
- projects table: changed description to TEXT (from VARCHAR)
- vacancies table: changed age to TINYINT(4) (from VARCHAR)
- applicants table: changed qualification, expecience and comments to TEXT (from VARCHAR) and salary_expectation to FLOAT (from VARCHAR)
- added leave_request_status table
- added applicant_status table

#NOTE: This is not optimized for lots of users. It will start to load slower with more data
