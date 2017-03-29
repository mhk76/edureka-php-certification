<?php

class Database
{
	private $cn;
	private $data;
	public $rowCount;
	public $isValid;
	public $success;
	public $invalid;

	public function __construct()
	{
		$this->rowCount = null;
		$this->isValid = true;
		$this->invalid = [];

		$this->cn = new mysqli('localhost', 'root', 'Teppo1+0');
		if ($this->cn->connect_error)
		{
			die('{"error":"Failed to connect to database"}');
		}

		$rs = $this->cn->query("SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'hr_management_system';");

		if ($rs->num_rows == 0)
		{
			die('{"error":"Database was not found"}');
		}

		$this->cn->query("USE hr_management_system;");

		$rs = $this->cn->query("SELECT 1 FROM employees WHERE username = 'admin';");

		if (!$rs)
		{
			die('{"error":"Admin was not found"}');
		}

		if ($rs->num_rows == 0)
		{
			$this->cn->query(
				"INSERT INTO employees ".
				"(designation_id, first_name, last_name, joining_date, username, password, status) ".
				"VALUES ".
				"(1, 'System', 'Administrator', CURRENT_TIMESTAMP, 'admin', '".password_hash('admin', PASSWORD_DEFAULT)."', 1);"
			);
		}
	}

	public function query($sql, $parameters = null, $rowsAsObject = false)
	{
		try
		{
			if ($parameters != null)
			{
				foreach ($parameters as $key=>$value)
				{
					if ($value == null)
					{
						$sql = str_replace("@$key", "NULL", $sql);
					}
					else if (gettype($value) == 'string')
					{
						$sql = str_replace("@$key", "'".$this->cn->real_escape_string($value)."'", $sql);
					}
					else
					{
						$sql = str_replace("@$key", $this->cn->real_escape_string((string)$value), $sql);
					}
				}
			}

			$rs = $this->cn->query($sql);

			if (!$rs)
			{
				$this->success = false;
				writeLog($sql);
				writeLog($this->cn->error);
				return [];
			}

			$this->success = true;
			$this->rowCount = $rs->num_rows;

			if ($this->rowCount == null)
			{
				return null;
			}

			$fieldNames = [];
			foreach ($rs->fetch_fields() as $field)
			{
				$fieldNames[] = lcfirst(str_replace("_", "", ucwords($field->name, '_')));
			}

			$keyField = $fieldNames[0];

			$rows = [];
			while($rowData = $rs->fetch_row())
			{
				$row = [];
				$index = 0;

				foreach ($rowData as $value)
				{
					$row[$fieldNames[$index]] = $value;
					$index++;
				}

				if ($rowsAsObject)
				{
					$rows[$row[$keyField]] = $row;
				}
				else
				{
					$rows[] = $row;
				}
			}
			$rs->close();

			return $rows;
		}
		catch (Exception $err)
		{
			return ['error'=>$err.getMessage()];
		}
	}

	public function setData($data)
	{
		$this->data = $data;
		$this->isValid = true;
		$this->invalid = [];
	}

	public function validateInt($name, $required = false, $min = null, $max = null)
	{
		$str = @$this->data[$name];

		if ($str == null and !$required)
		{
			return null;
		}
		if (!is_int($str))
		{
			$this->invalid[] = $name;
			$this->isValid = false;
			return null;
		}

		$int = intval($str);

		if ($min != null)
		{
			if ($int < $min)
			{
				$this->invalid[] = $name;
				$this->isValid = false;
				return null;
			}
			if ($max != null and $int > $max)
			{
				$this->invalid[] = $name;
				$this->isValid = false;
				return null;
			}
		}

		return $int;
	}

	public function validateFloat($name, $required = false, $min = null, $max = null)
	{
		$str = @$this->data[$name];

		if ($str == null and !$required)
		{
			return null;
		}
		if (!is_numeric($str))
		{
			$this->invalid[] = $name;
			$this->isValid = false;
			return null;
		}

		$float = floatval($str);

		if ($min != null)
		{
			if ($float < $min)
			{
				$this->invalid[] = $name;
				$this->isValid = false;
				return null;
			}
			if ($max != null and $float > $max)
			{
				$this->invalid[] = $name;
				$this->isValid = false;
				return null;
			}
		}

		return $float;
	}

	public function validateVarchar($name, $required = false, $max = null)
	{
		$str = @$this->data[$name];

		if (($str == null or strlen($str) == 0) and !$required)
		{
			return null;
		}
		if ($max != null and strlen($str) > $max)
		{
			$this->invalid[] = $name;
			$this->isValid = false;
			return null;
		}

		return $str;
	}

	public function validateDate($name, $required = false)
	{
		$str = @$this->data[$name];

		if ($str == null and !$required)
		{
			return null;
		}

		$date = $this->parseISODate($str);

		if ($date == null)
		{
			$this->invalid[] = $name;
			$this->isValid = false;
			return null;
		}

		return date('Y-m-d\TH:i:s', $date);
	}

	public function parseISODate($str)
	{
		if (preg_match('/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z|(\+|-)\d{2}(:?\d{2})?)$/', $str, $parts))
		{
			return gmmktime($parts[4], $parts[5], $parts[6], $parts[2], $parts[3], $parts[1]);
		}
			if (preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $str, $parts))
		{
			return gmmktime($parts[1], $parts[2], $parts[3], 0, 0, 0);
		}
		return null;
	}

	public function __destruct()
	{
		$this->cn->close();
	}
}

?>