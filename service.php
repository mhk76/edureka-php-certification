<?php

session_start();

header('Content-Type: text/json');

require('database.php');

$database = new Database();

$post = file_get_contents("php://input");
$post = ($post == null) ? array() : json_decode($post, TRUE);

//$post = $_GET;

$json = (object)[];

try
{
	switch (@$post['action'])
	{
		case 'init':
			$json = [];
			$json['user'] = @$_SESSION['user'];
			$json['projects'] = getProjects($database);
			$json['vacancies'] = getVacancies($database);
			getUserInfo($json);
			break;
		case 'login':
			$json = checkLogin();
			getUserInfo($json);
			break;
		case 'logout':
			session_unset();
			session_destroy(); 
			$json = [];
			break;
		case 'insertEmployee':
			$json = insertEmployee();
			break;
		default:
			$json = ['error'=>'Unknown error'];
			break;
	}
}
catch (Exception $e)
{
	writeLog($e);
	$json = ['error'=>'Unknown error'];
}

echo json_encode((object)$json, JSON_NUMERIC_CHECK);


function writeLog($message)
{
	$f = fopen('error.log', 'a+');
	fputs($f, date('Y-m-d H:i:s ', time()));
	fputs($f, $message.PHP_EOL);
	fclose($f);
}


function checkLogin()
{
	global $database, $post;

	$user = @$_SESSION['user'];

	if ($user != null)
	{
		return ['user'=>$user];
	}

	$username = @$post['username'];
	$password = @$post['password'];

	$rows = $database->query(
		"SELECT ".
		"	employee_id, ".
		"	designation_id, ".
		"	first_name, ".
		"	last_name, ".
		"	address, ".
		"	contact_no, ".
		"	joining_date, ".
		"	username, ".
		"	password, ".
		"	basic_pay, ".
		"	create_date ".
		"FROM employees ".
		"WHERE ".
		"	username = @username".
		"	AND status = 1;",
		['username'=>$username]
	);

	if ($database->row_count == 0)
	{
		return ['error'=>'Login failed'];
	}

	$row = $rows[0];

	if (!password_verify($password, $row['password']))
	{
		return ['error'=>'Login failed'];
	}

	unset($row['password']);

	$_SESSION['user'] = $row;

	return ['user'=>$row];
}

function getProjects()
{
	global $database;

	return $database->query(
		"SELECT ".
		"	project_id, ".
		"	project_title, ".
		"	description, ".
		"	start_date, ".
		"	end_date, ".
		"	status ".
		"FROM projects;"
	);
}

function getVacancies()
{
	global $database;

	return $database->query(
		"SELECT ".
		"	v.vacancy_id, ".
		"	v.title, ".
		"	d.designation_name, ".
		"	v.description, ".
		"	v.qualification, ".
		"	v.experience, ".
		"	v.age, ".
		"	v.last_application_date ".
		"FROM vacancies AS v ".
		"INNER JOIN designations AS d ON".
		"	d.designation_id = v.designation_id ".
		"WHERE ".
		"	v.status = 1;"
	);
}

function GetUserInfo(&$json)
{
	$user = @$_SESSION['user'];

	if ($user == null)
	{
		return;
	}

	$json['designations'] = getDesignations();

	if ($user['designationId'] == 1)
	{
		$json['leaveRequests'] = getLeaveRequests();
		$json['employees'] = getEmployees();
	}
	else
	{
		$json['attendance'] = getAttendance($user['employeeId']);
	}
}

function getDesignations()
{
	global $database;

	return $database->query(
		"SELECT ".
		"	designation_id, ".
		"	designation_name, ".
		"	description ".
		"FROM designations ".
		"ORDER BY ".
		"	designation_id;",
		null,
		true
	);
}

function getLeaveRequests()
{
	global $database;

	return $database->query(
		"SELECT ".
		"	lr.leave_id, ".
		"	lr.employee_id, ".
		"	CONCAT(e.first_name, ' ', e.last_name) AS employee_name, ".
		"	lr.leave_from, ".
		"	lr.leave_to, ".
		"	lr.reason ".
		"FROM leave_requests AS lr ".
		"INNER JOIN employees AS e ON".
		"	e.employee_id = lr.employee_id ".
		"WHERE ".
		"	lr.status = 0;"
	);
}

function getEmployees($id = null)
{
	global $database;

	$cmd = 
		"SELECT ".
		"	employee_id, ".
		"	designation_id, ".
		"	first_name, ".
		"	last_name, ".
		"	address, ".
		"	contact_no, ".
		"	joining_date, ".
		"	username, ".
		"	basic_pay, ".
		"	create_date, ".
		"	status ".
		"FROM employees";

	if ($id != null)
	{
		$cmd = $cmd." ".
			"WHERE ".
			"	employee_id = ".$id;
	}

	return $database->query($cmd.";");
}

function getAttendance($employeeId)
{
	global $database;

	return $database->query(
		"SELECT ".
		"	time_in, ".
		"	time_out ".
		"FROM attendance ".
		"WHERE ".
		"	employee_id = @employeeId ".
		"	AND DATE(time_in) = CURDATE() ".
		"	AND ( ".
		"		time_out IS NULL ".
		"		OR DATE(time_out) = CURDATE()".
		"	);",
		['employeeId'=>$employeeId]
	);
}

function insertEmployee()
{
	$user = @$_SESSION['user'];

	if ($user == null or @$user['designationId'] == null or $user['designationId'] != 1)
	{
		return ['error'=>'Denied'];
	}

	global $database, $post;

	$database->setData(@$post);

	$designationId = $database->validateInt('designationId', true, 1);
	$firstName = $database->validateVarchar('firstName', true, 50);
	$lastName = $database->validateVarchar('lastName', true, 50);
	$address = $database->validateVarchar('address', false, 100);
	$contactNo = $database->validateVarchar('contactNo', false, 20);
	$joiningDate = $database->validateDate('joiningDate', true);
	$username = $database->validateVarchar('username', true, 50);
	$password = $database->validateVarchar('password', true, 50);
	$basicPay = $database->validateFloat('basicPay', false);

	if (!$database->isValid)
	{
		return ['error'=>'Invalid data'];
	};

	$rs = $database->query(
		"SELECT ".
		"	1 ".
		"FROM employees ".
		"WHERE ".
		"	username = @username;",
		['username'=>$username]
	);

	if ($database->rowCount > 0)
	{		
		return ['error'=>'Username already taken'];
	}

	$database->query(
		"INSERT INTO employees ".
		"( ".
		"	designation_id, ".
		"	first_name, ".
		"	last_name, ".
		"	address, ".
		"	contact_no, ".
		"	joining_date, ".
		"	username, ".
		"	password, ".
		"	basic_pay, ".
		"	status ".
		") ".
		"SELECT ".
		"	@designationId,".
		"	@firstName,".
		"	@lastName,".
		"	@address,".
		"	@contactNo,".
		"	@joiningDate,".
		"	@username,".
		"	@password,".
		"	@basicPay,".
		"	1;",
		[
			'designationId'=>$designationId,
			'firstName'=>$firstName,
			'lastName'=>$lastName,
			'address'=>$address,
			'contactNo'=>$contactNo,
			'joiningDate'=>$joiningDate,
			'username'=>$username,
			'password'=>password_hash($password, PASSWORD_DEFAULT),
			'basicPay'=>$basicPay
		]
	);

	if ($database->success)
	{
		return getEmployees('LAST_INSERT_ID()');
	}

	return ['error'=>'Database error'];
}

?>