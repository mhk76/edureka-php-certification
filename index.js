'use strict';
var $ = angular.extend(
	angular.element,
	{
		extend: angular.extend,
		isFunction: angular.isFunction,
		copy: angular.copy,
		equals: angular.equals,
		forEach: angular.forEach
	}
);
angular.module('appDevTechApp', [])
.controller('appDevTechController', function($scope, postData, showDialog)
{
	$scope.data = {
		screenWidth: screen.width,
		screenHeight: screen.height,
		user: {},
		projects: [],
		vacancies: []
	};
	$scope.show = {
		view: 'home',
		list: 'leaveRequests',
		login: false
	};
	$scope.listLinks = [];

	postData('init').then(function(data)
	{
		initUser(data);
	});

	$scope.setView = function(view)
	{
		$scope.show.view = view;
	};

	$scope.showLogin = function()
	{
		$scope.show.login = true;
	}

	$scope.login = function(username, password)
	{
		postData(
			'login',
			{
				username: username,
				password: password
			}
		).then(function(data)
		{
			initUser(data);
			$scope.show.login = false;
		});
	};

	$scope.logout = function ()
	{
		postData('logout').then(function(data)
		{
			$scope.data.user = null;
		});
	}

	$scope.editEmployee = function(employee)
	{		
		$scope.editedEmployee = employee;
		$scope.show.employee = true;
	}

	$scope.saveEmployee = function(employee)
	{
console.log(employee)
		if (!employee.designationId)
		{
			showDialog('Must have a designation', function() { $scope.selectByModel('employee.designationId'); });
			return true;
		}
		if (!employee.firstName || employee.firstName.length === 0)
		{
			showDialog('Must have first name', function() { $scope.selectByModel('employee.firstName'); });
			return true;
		}
		if (!employee.lastName || employee.lastName.length === 0)
		{
			showDialog('Must have last name', function() { $scope.selectByModel('employee.lastName'); });
			return true;
		}
		if (!employee.username || employee.username.length === 0)
		{
			showDialog('Must have username', function() { $scope.selectByModel('employee.username'); });
			return true;
		}
		if (employee.changePassword)
		{
			if (!employee.password || employee.password.length === 0)
			{
				showDialog('Must set password', function() { $scope.selectByModel('employee.password'); });
				return true;
			}
			if (employee.password.length < 6)
			{
				showDialog('The password is too short (min. 6 characters)', function() { $scope.selectByModel('employee.password'); });
				return true;
			}
			if (!employee.password2 || employee.password !== employee.password2)
			{
				showDialog('Passwords don\'t match', function() { $scope.selectByModel('employee.password2'); });
				return true;
			}
		}

		var _this = this;

		if (employee.employeeId)
		{
			postData('saveEmployee', employee).then(function()
			{
				_this.closeDialog();
			});
		}
		else
		{
			postData('insertEmployee', employee).then(function(newUser)
			{
				$scope.data.employees.push(newUser);
				_this.closeDialog();
			});
		}

		return true;
	};

	$scope.selectByModel = function(name)
	{
		var element = document.body.querySelector('[data-ng-model="' + name + '"]');

		element.focus();
		if (element.select)
		{
			element.select();
		}
	}

	$scope.formatDate = function (date)
	{
		var dt = new Date(date);

		if (dt == 'Invalid date')
		{
			return '';
		}
		return dt.toLocaleDateString();
	}

	$scope.formatDateTime = function (date)
	{
		var dt = new Date(date);

		if (isNaN(dt.getTime()))
		{
			return '-';
		}
		return dt.toLocaleString();
	}

	function initUser(data)
	{
		$.extend($scope.data, data);

		if ($scope.data.user.designationId == 1)
		{
			$scope.show.view = 'user';

			$scope.userUrl = 'admin.html';
			$scope.show.list = 'leaveRequests';

			$scope.listLinks = [
				{ key: 'leaveRequests', title: 'Leave requests' },
				{ key: 'employees', title: 'Employees' },
				{ key: 'projects', title: 'Projects' },
				{ key: 'designations', title: 'Designations' },
				{ key: 'vacancies', title: 'Vacancies' },
				{ key: 'attendance', title: 'Attendance' },
				{ key: 'schedule', title: 'Interview schedule' },
			];
		}
	}
})
.factory('postData', function($q, $http, showDialog)
{
	return function(action, data)
	{
		var defer = $q.defer();
console.log($.extend({}, data, { action: action }))
		$http({
			method: 'POST',
			url: 'service.php',
			header: {
				'Content-Type': 'text/json'
			},
			data: $.extend({}, data, { action: action })
		}).then(function(response)
		{
			if (response.status == 200)
			{
				if (response.data.error)
				{
					showDialog(response.data.error);
					defer.reject();
				}
				else
				{
					defer.resolve(response.data);
				}
			}
			else
			{
				console.log(response);
				defer.reject();
			}
		});

		return defer.promise;
	};
})
.directive('dialog', function(showDialog)
{
	var zIndex = 1000;

	return {
		scope: true,
		link: function($scope, $element, $attributes, $controller)
		{
			var $frame = $('<div class="dialogFrame"></div>');
			var $mask = $('<div class="dialogMask ng-hide"></div>');
			var focus = $attributes.focus;

			$frame.attr(
				'style',
				'width:' + ($attributes.width || '30rem')
				+ ';height:' + ($attributes.height || '20rem')
				+ ';left:calc(50% - ' + ($attributes.width || '30rem') + ' / 2)'
				+ ';top:calc(40% - ' + ($attributes.height || '20rem') + ' / 2)'
			);

			$element.addClass('dialog');
			$element.wrap($frame);

			$frame = $element.parent();

			$(document.body).append($mask);
			$(document.body).append($frame);

			var $watch = $scope.$parent.$watch(
				$attributes.dialog,
				function(value)
				{
					var hide = (value !== true);

					$frame.toggleClass('ng-hide', hide);
					$mask.toggleClass('ng-hide', hide);

					if (hide)
					{
						zIndex -= 2;
						if (zIndex < 1000)
						{
							zIndex = 1000;
						}
					}
					else
					{
						$scope[$attributes.dataAlias || $attributes.data] = $.copy($scope.$eval($attributes.data));
						$mask.css({ 'z-index': zIndex });
						++zIndex;
						$frame.css({ 'z-index': zIndex });
						++zIndex;
						if (focus)
						{
							$scope.selectByModel(focus);
						}
					}
				}
			);

			$scope.closeDialog = function(force)
			{
				if (!force)
				{console.log($scope[$attributes.dataAlias || $attributes.data], $scope.$eval($attributes.data))
					if (!$.equals($scope[$attributes.dataAlias || $attributes.data], $scope.$eval($attributes.data)))
					{
						showDialog(
							'The data has been changed! Abandon changes?',
							[
								{ title: 'Yes', click: function() { $scope.closeDialog(true); } },
								{ title: 'No' }
							]
						);
						return; 
					}
				}

				$scope.$parent.$applyAsync(function()
				{
					$scope.$parent.$eval($attributes.dialog + '=false');
				})

				zIndex -= 2;
			};

			$scope.killDialog = function() 
			{
				$frame.remove();
				$watch();
				$mask.remove();
				$scope.$destroy();
			};
		}
	};
})
.factory('showDialog', function($rootScope, $compile)
{
	return function (message, buttons, height)
	{
		var dialog = $('<div data-dialog="true" width="32rem" height="' + (height || '5rem') + '">');

		dialog.append(
			$('<div></div>')
				.text(message)
		);

		var buttonBar = $('<div class="buttons"></div>');
		
		dialog.append(buttonBar);

		if ($.isFunction(buttons))
		{
			buttons = [{ title: 'Close', click: buttons }];
		}
		else
		{
			buttons = buttons || [];
		}

		if (buttons.length === 0)
		{
			buttons.push({ title: 'Close' });
		}

		$.forEach(
			buttons,
			function(button)
			{
				buttonBar.append(
					$('<span class="link"></span>')
						.text(button.title)
						.on('click', function()
						{
							if (button.click)
							{
								if (button.click())
								{
									return;
								};
							}
							$dialog.scope().killDialog();
						})
				);
			}
		);

		$(document.body).append(dialog);

		var $dialog = $compile(dialog)($rootScope);
	}
})
.directive('asDate', function()
{
    return {
		require: 'ngModel',
        restrict : 'A',
        link: function ($scope, $element, $attributes, $controller)
		{
			$controller.$formatters.length = 0;
			$controller.$parsers.length = 0;

            var release = $scope.$watch(
				$attributes.ngModel,
				function (value)
				{
					if (value)
					{
						$scope.ngModel = new Date(value);
					}
				}
			);

			$scope.$on('$destroy', function()
			{
				release();
			});
        }
    }
})
.directive('required', function()
{
    return {
		require: 'ngModel',
        restrict : 'A',
        link: function ($scope, $element, $attributes)
		{
			function isMissing()
			{
				var value = $scope.$eval($attributes.ngModel);
				var missing = (value == null || value === "");

				$element.toggleClass('missing', missing);

				return missing;
			}

			$element.on('blur', function()
			{
				if (isMissing())
				{
					$element[0].focus();
					return;
				}
			})
			$element.after('<span class="required" title="This field is required">*</span>');

            var release = $scope.$watch(
				$attributes.ngModel,
				function (value)
				{
					isMissing();
				}
			);

			$scope.$on('$destroy', function()
			{
				release();
			});
		}
	};
});