-- MySQL dump 10.13  Distrib 5.7.16, for Win64 (x86_64)
--
-- Host: localhost    Database: hr_management_system
-- ------------------------------------------------------
-- Server version	5.7.16-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `applicant_status`
--

DROP TABLE IF EXISTS `applicant_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `applicant_status` (
  `applicant_status_id` tinyint(4) NOT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`applicant_status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applicant_status`
--

LOCK TABLES `applicant_status` WRITE;
/*!40000 ALTER TABLE `applicant_status` DISABLE KEYS */;
INSERT INTO `applicant_status` VALUES (1,'Applied'),(2,'Under initial review'),(3,'Shortlisted for interview'),(4,'Interview scheduled'),(5,'Application rejected'),(6,'Final selection');
/*!40000 ALTER TABLE `applicant_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `applicants`
--

DROP TABLE IF EXISTS `applicants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `applicants` (
  `applicant_id` int(11) NOT NULL AUTO_INCREMENT,
  `vacancy_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(5) NOT NULL,
  `contact_no` varchar(20) NOT NULL,
  `email_id` varchar(100) NOT NULL,
  `date_of_birth` date NOT NULL,
  `qualification` text NOT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `salary_expectation` float NOT NULL,
  `experience` text NOT NULL,
  `comments` text NOT NULL,
  `application_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint(4) NOT NULL,
  PRIMARY KEY (`applicant_id`),
  KEY `fk_vacancy_id_idx` (`vacancy_id`),
  KEY `fk_status_idx` (`status`),
  CONSTRAINT `fk_applicants_status` FOREIGN KEY (`status`) REFERENCES `applicant_status` (`applicant_status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_applicants_vacancy_id` FOREIGN KEY (`vacancy_id`) REFERENCES `vacancies` (`vacancy_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applicants`
--

LOCK TABLES `applicants` WRITE;
/*!40000 ALTER TABLE `applicants` DISABLE KEYS */;
/*!40000 ALTER TABLE `applicants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `time_in` datetime NOT NULL,
  `time_out` datetime NOT NULL,
  PRIMARY KEY (`attendance_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `fk_attendance_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `designations`
--

DROP TABLE IF EXISTS `designations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `designations` (
  `designation_id` int(11) NOT NULL AUTO_INCREMENT,
  `designation_name` varchar(50) NOT NULL,
  `description` varchar(250) NOT NULL,
  PRIMARY KEY (`designation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `designations`
--

LOCK TABLES `designations` WRITE;
/*!40000 ALTER TABLE `designations` DISABLE KEYS */;
INSERT INTO `designations` VALUES (1,'Human resources','Main users');
/*!40000 ALTER TABLE `designations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees` (
  `employee_id` int(11) NOT NULL AUTO_INCREMENT,
  `designation_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `address` varchar(100) DEFAULT NULL,
  `contact_no` varchar(20) DEFAULT NULL,
  `joining_date` date NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `basic_pay` float DEFAULT NULL,
  `create_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `designation_id` (`designation_id`),
  CONSTRAINT `fk_employees_designation_id` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`designation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `interview_schedules`
--

DROP TABLE IF EXISTS `interview_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interview_schedules` (
  `interview_id` int(11) NOT NULL,
  `selection_round` varchar(20) NOT NULL,
  `vacancy_id` int(11) NOT NULL,
  `interview_date_time` datetime NOT NULL,
  `venue` varchar(100) NOT NULL,
  `contact_no` varchar(20) NOT NULL,
  `status` tinyint(1) NOT NULL,
  PRIMARY KEY (`interview_id`),
  KEY `vacancy_id` (`vacancy_id`),
  CONSTRAINT `fk_interview_schedules_vacancy_id` FOREIGN KEY (`vacancy_id`) REFERENCES `vacancies` (`vacancy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `interview_schedules`
--

LOCK TABLES `interview_schedules` WRITE;
/*!40000 ALTER TABLE `interview_schedules` DISABLE KEYS */;
/*!40000 ALTER TABLE `interview_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_request_status`
--

DROP TABLE IF EXISTS `leave_request_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leave_request_status` (
  `status_id` tinyint(4) NOT NULL,
  `description` varchar(20) NOT NULL,
  PRIMARY KEY (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_request_status`
--

LOCK TABLES `leave_request_status` WRITE;
/*!40000 ALTER TABLE `leave_request_status` DISABLE KEYS */;
INSERT INTO `leave_request_status` VALUES (0,'Pending'),(1,'Approved'),(2,'Rejected');
/*!40000 ALTER TABLE `leave_request_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leave_requests` (
  `leave_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `leave_from` datetime NOT NULL,
  `leave_to` datetime NOT NULL,
  `reason` varchar(200) NOT NULL,
  `status` tinyint(4) NOT NULL,
  PRIMARY KEY (`leave_id`),
  KEY `employee_id` (`employee_id`),
  KEY `status` (`status`),
  CONSTRAINT `fk_leave_requests_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `fk_leave_requests_status` FOREIGN KEY (`status`) REFERENCES `leave_request_status` (`status_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `project_allocations`
--

DROP TABLE IF EXISTS `project_allocations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_allocations` (
  `proj_allocation_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `comment` varchar(250) NOT NULL,
  PRIMARY KEY (`proj_allocation_id`),
  KEY `project_id` (`project_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `fk_project_allocations_employee_id` FOREIGN KEY (`employee_id`) REFERENCES `designations` (`designation_id`),
  CONSTRAINT `fk_project_allocations_project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `project_allocations`
--

LOCK TABLES `project_allocations` WRITE;
/*!40000 ALTER TABLE `project_allocations` DISABLE KEYS */;
/*!40000 ALTER TABLE `project_allocations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `project_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_title` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `status` tinyint(1) NOT NULL,
  PRIMARY KEY (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vacancies`
--

DROP TABLE IF EXISTS `vacancies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vacancies` (
  `vacancy_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `designation_id` int(11) NOT NULL,
  `description` text NOT NULL,
  `qualification` varchar(100) NOT NULL,
  `experience` float NOT NULL,
  `age` tinyint(4) DEFAULT NULL,
  `last_application_date` date NOT NULL,
  `status` tinyint(1) NOT NULL,
  PRIMARY KEY (`vacancy_id`),
  KEY `designation_id` (`designation_id`),
  CONSTRAINT `fk_vacancies_designation_id` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`designation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vacancies`
--

LOCK TABLES `vacancies` WRITE;
/*!40000 ALTER TABLE `vacancies` DISABLE KEYS */;
/*!40000 ALTER TABLE `vacancies` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-12-19  0:05:34
