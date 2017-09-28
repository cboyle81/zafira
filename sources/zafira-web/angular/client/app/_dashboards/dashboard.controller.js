(function () {
    'use strict';

    angular
        .module('app.dashboard')
        .controller('DashboardController', ['$scope', '$rootScope', '$timeout', '$cookies', '$location', '$state', '$http', '$mdConstant', '$stateParams', '$mdDialog', 'UtilService', 'DashboardService', 'UserService', 'AuthService', 'ProjectProvider', DashboardController])

    function DashboardController($scope, $rootScope, $timeout, $cookies, $location, $state, $http, $mdConstant, $stateParams, $mdDialog, UtilService, DashboardService, UserService, AuthService, ProjectProvider) {

        $scope.dashboardId = null;
        $scope.currentUserId = $location.search().userId;

        $scope.dashboard = {};

        $scope.loadDashboardData = function (dashboard, refresh) {
            for (var i = 0; i < dashboard.widgets.length; i++) {
                if ('sql' != dashboard.widgets[i].type) {
                    if (!refresh || refresh && dashboard.widgets[i].refreshable) {
                        $scope.loadWidget(dashboard.title, dashboard.widgets[i], dashboard.attributes, refresh);
                    }
                }
            }
        };

        $scope.loadWidget = function (dashboardName, widget, attributes, refresh) {
            var sqlAdapter = {'sql': widget.sql, 'attributes': attributes};
            var params = ProjectProvider.getProjectQueryParam();
            for(var i = 0; i<$scope.dashboard.attributes.length; i++){
                if ($scope.dashboard.attributes[i].key != null && $scope.dashboard.attributes[i].key == 'project'){
                    params = "?project=" + $scope.dashboard.attributes[i].value;
                }
    		}
            params = params != "" ? params + "&dashboardName=" + dashboardName : params + "?dashboardName=" + dashboardName;
            if ($scope.currentUserId) {
                params = params + "&currentUserId=" + $scope.currentUserId;
            }
            if(!refresh){
                $scope.isLoading = true;
            }
            DashboardService.ExecuteWidgetSQL(params, sqlAdapter).then(function (rs) {
                if (rs.success) {
                    var data = rs.data;
                    for (var j = 0; j < data.length; j++) {
                        if (data[j].CREATED_AT) {
                            data[j].CREATED_AT = new Date(data[j].CREATED_AT);
                        }
                    }

                    if ('sql' != widget.type) {
                        if(!refresh){
                            widget.model = JSON.parse(widget.model);
                        }
                        widget.data = {};
                        widget.data.dataset = data;
                    }
                    if (data.length != 0) {
                        $scope.isLoading = false;
                    }
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.asString = function (value) {
            if (value) {
                value = value.toString();
            }
            return value;
        };

        $scope.sort = {
            column: null,
            descending: false
        };

        $scope.changeSorting = function(column) {
            var specCharRegexp = /[-[\]{}()*+?.,\\^$|#\s%]/g;

            if (column.search(specCharRegexp) != -1) {
                // handle by quotes from both sides
                 column = "\"" + column + "\"";
             }
            var sort = $scope.sort;
            if (sort.column == column) {
                sort.descending = !sort.descending;
            } else {
                sort.column = column;
                sort.descending = false;
            }
        };

        $scope.showDashboardWidgetDialog = function (event, widget, isNew) {
            $mdDialog.show({
                controller: DashboardWidgetController,
                templateUrl: 'app/_dashboards/dashboard_widget_modal.html',
                parent: angular.element(document.body),
                targetEvent: event,
                clickOutsideToClose: true,
                fullscreen: true,
                locals: {
                    widget: widget,
                    isNew: isNew,
                    dashboardId: $scope.dashboardId
                }
            })
                .then(function (answer) {
                	if(answer == true) $state.reload();
                }, function () {
                });
        };

        $scope.showDashboardDialog = function (event, dashboard, isNew) {
            $mdDialog.show({
                controller: DashboardSettingsController,
                templateUrl: 'app/_dashboards/dashboard_modal.html',
                parent: angular.element(document.body),
                targetEvent: event,
                clickOutsideToClose: true,
                fullscreen: true,
                locals: {
                    dashboard: dashboard,
                    isNew: isNew
                }
            })
                .then(function (answer) {
                	if(answer == true) $state.reload();
                }, function () {
                });
        };

        $scope.showWidgetDialog = function (event, widget, isNew, dashboard) {
            $mdDialog.show({
                controller: WidgetController,
                templateUrl: 'app/_dashboards/widget_modal.html',
                parent: angular.element(document.body),
                targetEvent: event,
                clickOutsideToClose: false,
                backdrop: 'static',
                fullscreen: true,
                locals: {
                    widget: widget,
                    isNew: isNew,
                    dashboard: dashboard,
                    currentUserId: $scope.currentUserId
                }
            })
                .then(function (answer) {
                	if(answer == true) $state.reload();
                }, function () {
                });
        };

        $scope.showEmailDialog = function (event) {
            $mdDialog.show({
                controller: EmailController,
                templateUrl: 'app/_dashboards/email_modal.html',
                parent: angular.element(document.body),
                targetEvent: event,
                clickOutsideToClose: true,
                fullscreen: true
            })
                .then(function (answer) {
                }, function () {
                });
        };

        var toAttributes = function (qParams) {
            var attributes = [];
            for(var param in qParams) {
                var currentAttribute = {};
                currentAttribute.key = param;
                currentAttribute.value = qParams[param];
                attributes.push(currentAttribute);
            }
            return attributes;
        };

        var getQueryAttributes = function () {
            var qParams = $location.search();
            var qParamsLength = Object.keys(qParams).length;
            if(qParamsLength > 0 && $stateParams.id) {
                return toAttributes(qParams);
            }
        };

        $scope.getDataWithAttributes = function (dashboard, refresh) {
            var queryAttributes = getQueryAttributes();
            if(queryAttributes) {
                for (var i = 0; i < queryAttributes.length; i++) {
                    dashboard.attributes.push(queryAttributes[i]);
                }
            }
            $scope.loadDashboardData(dashboard, refresh);
        };

        var refreshPromise;
        var isRefreshing = false;
        var interval = $rootScope.refreshInterval;

        $scope.startRefreshing = function(){
            if(isRefreshing) return;
            isRefreshing = true;
            (function refreshEvery(){
                if ($location.$$url.indexOf("dashboards") > -1){
                    if (typeof $scope.dashboard.title !== 'undefined' && typeof interval !== 'undefined' && interval != 0){
                        $scope.loadDashboardData($scope.dashboard, true);
                    }
                    refreshPromise = $timeout(refreshEvery, interval)
                }
         }());
        };


        $scope.$watch(
            function() {
                if (typeof $scope.currentUserId !== 'undefined' && typeof $location.$$search.userId !== 'undefined'){
                    return $scope.currentUserId !== $location.$$search.userId;
                }
            },
            function() {
                if (typeof $scope.currentUserId !== 'undefined' && typeof $location.$$search.userId !== 'undefined') {
                    if ($scope.currentUserId !== $location.$$search.userId) {
                        $scope.currentUserId = $location.search().userId;
                        DashboardService.GetDashboardById($scope.dashboardId).then(function (rs) {
                            if (rs.success) {
                                $scope.dashboard = rs.data;
                                $scope.getDataWithAttributes($scope.dashboard, false);
                            }
                        });
                    }
                }
            }
        );

        (function init() {

        	var token = $cookies.get("Access-Token") ? $cookies.get("Access-Token") : $rootScope.globals.auth.refreshToken;

        	AuthService.RefreshToken(token)
    		.then(
            function (rs) {
            	if(rs.success)
            	{
            		AuthService.SetCredentials(rs.data);

            		DashboardService.GetDashboards().then(function (rs) {
                        if (rs.success) {
                            if($stateParams.id){
                                $scope.dashboardId = $stateParams.id;
                                DashboardService.GetDashboardById($stateParams.id).then(function (rs) {
                                    if (rs.success) {
                                        $scope.dashboard = rs.data;
                                        $scope.getDataWithAttributes($scope.dashboard, false);
                                    }
                                });
                            }
                            else {
                                DashboardService.GetDashboardByTitle($rootScope.defaultDashboard).then(function(rs) {
                                    if(rs.success)
                                    {
                                        $scope.dashboardId = rs.data.id;
                                        $scope.dashboard = rs.data;
                                        $scope.getDataWithAttributes($scope.dashboard, false);
                                    }
                                });
                            }
                        }
                    });

            		DashboardService.GetWidgets().then(function (rs) {
                        if (rs.success) {
                            $scope.widgets = rs.data;
                        } else {
                            alertify.error(rs.message);
                        }
                    });
            	}
            });
            $scope.startRefreshing();
        })();
    }

    // **************************************************************************
    function DashboardWidgetController($scope, $mdDialog, DashboardService, widget, dashboardId, isNew) {

        $scope.isNew = isNew;
        $scope.widget = widget;

        if (isNew) {
            $scope.widget.position = 0;
            $scope.widget.size = 4;
        }

        $scope.addDashboardWidget = function (widget) {
            DashboardService.AddDashboardWidget(dashboardId, widget).then(function (rs) {
                if (rs.success) {
                	alertify.success("Widget added");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.deleteDashboardWidget = function (widget) {
            DashboardService.DeleteDashboardWidget(dashboardId, widget.id).then(function (rs) {
                if (rs.success) {
                	alertify.success("Widget deleted");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.updateDashboardWidget = function (widget) {
            DashboardService.UpdateDashboardWidget(dashboardId, {
                "id": widget.id,
                "size": widget.size,
                "position": widget.position
            }).then(function (rs) {
                if (rs.success) {
                	alertify.success("Widget updated");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.hide = function (result) {
            $mdDialog.hide(result);
        };
        $scope.cancel = function () {
            $mdDialog.cancel();
        };
        (function initController() {
        })();
    }

    function DashboardSettingsController($scope, $mdDialog, $location, DashboardService, dashboard, isNew) {

        $scope.isNew = isNew;
        $scope.dashboard = dashboard;
        $scope.newAttribute = {};

        if($scope.isNew)
        {
            $scope.dashboard.hidden = false;
        }

        $scope.createDashboard = function(dashboard){
            DashboardService.CreateDashboard(dashboard).then(function (rs) {
                if (rs.success) {
                	alertify.success("Dashboard created");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.updateDashboard = function(dashboard){
            dashboard.widgets = null;
            DashboardService.UpdateDashboard(dashboard).then(function (rs) {
                if (rs.success) {
                	alertify.success("Dashboard updated");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.deleteDashboard = function(dashboard){
            DashboardService.DeleteDashboard(dashboard.id).then(function (rs) {
                if (rs.success)
                {
                	alertify.success("Dashboard deleted");
                    var mainDashboard = $location.$$absUrl.substring(0, $location.$$absUrl.lastIndexOf('/'));
                    window.open(mainDashboard, '_self');
                }
                else {
                    alertify.error(rs.message);
                }
            });
            $scope.hide();
        };

        // Dashboard attributes
        $scope.createAttribute = function(attribute){
            DashboardService.CreateDashboardAttribute(dashboard.id, attribute).then(function (rs) {
                if (rs.success) {
                    $scope.dashboard.attributes = rs.data;
                    $scope.newAttribute = {};
                    alertify.success('Dashboard attribute created');
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.updateAttribute = function(attribute){
            DashboardService.UpdateDashboardAttribute(dashboard.id, attribute).then(function (rs) {
                if (rs.success) {
                    $scope.dashboard.attributes = rs.data;
                    alertify.success('Dashboard attribute updated');
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.deleteAttribute = function(attribute){
            DashboardService.DeleteDashboardAttribute(dashboard.id, attribute.id).then(function (rs) {
                if (rs.success) {
                    $scope.dashboard.attributes = rs.data;
                    alertify.success('Dashboard attribute removed');
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.hide = function (result) {
            $mdDialog.hide(result);
        };
        $scope.cancel = function () {
            $mdDialog.cancel();
        };
        (function initController() {
        })();
    }

    function WidgetController($scope, $rootScope, $mdDialog, DashboardService, ProjectProvider, widget, isNew, dashboard, currentUserId) {

        $scope.currentUserId = currentUserId;
        $scope.isNew = isNew;
        $scope.widget = widget;
        $scope.dashboard = dashboard;
        $scope.showWidget = false;


        if($scope.isNew && $scope.widget)
        {
            $scope.widget.id = null;
        }

        $scope.createWidget = function(widget){
            DashboardService.CreateWidget(widget).then(function (rs) {
                if (rs.success) {
                	alertify.success("Widget created");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.updateWidget = function(widget){
            DashboardService.UpdateWidget(widget).then(function (rs) {
                if (rs.success) {
                	alertify.success("Widget updated");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
            $scope.hide(true);
        };

        $scope.deleteWidget = function(widget){
            DashboardService.DeleteWidget(widget.id).then(function (rs) {
                if (rs.success) {
                	alertify.success("Widget deleted");
                	$scope.hide(true);
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $rootScope.$on("$event:executeSQL", function () {
            $scope.loadModalWidget($scope.widget, true);
        });

        $rootScope.$on("$event:showWidget", function () {
            $scope.loadModalWidget($scope.widget);
        });

        $scope.loadModalWidget = function (widget, table) {

            $scope.isLoading = true;
            widget.sql = widget.sql.replace(/\s*[\r\n]/gm, "");
            var sqlAdapter = {'sql': widget.sql};
            var params = ProjectProvider.getProjectQueryParam();
            for(var i = 0; i < $scope.dashboard.attributes.length; i++){
                if ($scope.dashboard.attributes[i].key !== null && $scope.dashboard.attributes[i].key === 'project'){
                    params = "?project=" + $scope.dashboard.attributes[i].value;
                }
            }
            params = params !== "" ? params + "&dashboardName=" + $scope.dashboard.title : params + "?dashboardName=" + $scope.dashboard.title;
            if ($scope.currentUserId) {
                params = params + "&currentUserId=" + $scope.currentUserId;
            }
            if (table) {
                params = params + "&stackTraceRequired=" + true;
            }
            DashboardService.ExecuteWidgetSQL(params, sqlAdapter).then(function (rs) {
                if (rs.success) {
                    var data = rs.data;
                    var columns = {};
                    for (var j = 0; j < data.length; j++) {
                        if(j == 0){
                            columns = Object.keys(data[j]);
                        }
                        if (data[j].CREATED_AT) {
                            data[j].CREATED_AT = new Date(data[j].CREATED_AT);
                        }
                    }
                    if ('sql' != widget.type) {
                        if (table){
                            widget.testType = 'table';
                            widget.testModel = {"columns" : columns};
                        }
                        else {
                            widget.testType = widget.type;
                            widget.testModel = JSON.parse(widget.model);
                        }
                        widget.data = {};
                        widget.data.dataset = data;
                    }
                    $scope.isLoading = false;
                    $scope.showWidget = true;
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };

        $scope.sort = {
            column: null,
            descending: false
        };

        $scope.changeSorting = function(column) {
            var specCharRegexp = /[-[\]{}()*+?.,\\^$|#\s%]/g;

            if (column.search(specCharRegexp) != -1) {
                // handle by quotes from both sides
                column = "\"" + column + "\"";
            }
            var sort = $scope.sort;
            if (sort.column == column) {
                sort.descending = !sort.descending;
            } else {
                sort.column = column;
                sort.descending = false;
            }
        };

        $scope.asString = function (value) {
            if (value) {
                value = value.toString();
            }
            return value;
        };

        $scope.closeWidget = function(){
            $scope.clearWidgetData();
            $scope.showWidget = false;
        };

        $scope.hide = function (result) {
            $mdDialog.hide(result);
        };

        $scope.cancel = function () {
            $scope.clearWidgetData();
            $mdDialog.cancel();
        };

        $scope.clearWidgetData = function () {
            $scope.widget.data = null;
            $scope.widget.testType = null;
        };
        (function initController() {
        })();
    }

    function EmailController($scope, $rootScope, $mdDialog, $mdConstant, DashboardService, UserService) {

        $scope.title = "Zafira Dashboard";
        $scope.subjectRequired = true;
        $scope.textRequired = true;

        $scope.email = {};
        $scope.email.subject = "Zafira Dashboards";
        $scope.email.text = "This is auto-generated email, please do not reply!";
        $scope.email.hostname = document.location.hostname;
        $scope.email.urls = [document.location.href];
        $scope.email.recipients = [];
        $scope.users = [];
        $scope.keys = [$mdConstant.KEY_CODE.ENTER, $mdConstant.KEY_CODE.TAB, $mdConstant.KEY_CODE.COMMA, $mdConstant.KEY_CODE.SEMICOLON, $mdConstant.KEY_CODE.SPACE];

        var currentText;

        $scope.sendEmail = function () {
            if (! $scope.users.length) {
                if (currentText && currentText.length) {
                    $scope.email.recipients.push(currentText);
                } else {
                    alertify.error('Add a recipient!');
                    return;
                }
            }
            $scope.hide();
            $scope.email.recipients = $scope.email.recipients.toString();
            DashboardService.SendDashboardByEmail($scope.email).then(function (rs) {
                if (rs.success) {
                    alertify.success('Email was successfully sent!');
                }
                else {
                    alertify.error(rs.message);
                }
            });
        };
        $scope.users_all = [];

        $scope.usersSearchCriteria = {};
        $scope.asyncContacts = [];
        $scope.filterSelected = true;

        $scope.querySearch = querySearch;
        var stopCriteria = '########';

        function querySearch(criteria, user) {
            $scope.usersSearchCriteria.email = criteria;
            currentText = criteria;
            if (!criteria.includes(stopCriteria)) {
                stopCriteria = '########';
                return UserService.searchUsersWithQuery($scope.usersSearchCriteria, criteria).then(function (rs) {
                    if (rs.success) {
                        if (! rs.data.results.length) {
                            stopCriteria = criteria;
                        }
                        return rs.data.results.filter(searchFilter(user));
                    }
                    else {
                    }
                });
            }
            return "";
        }

        function searchFilter(u) {
            return function filterFn(user) {
                var users = u;
                for(var i = 0; i < users.length; i++) {
                    if(users[i].id == user.id) {
                        return false;
                    }
                }
                return true;
            };
        }

        $scope.checkAndTransformRecipient = function (currentUser) {
            var user = {};
            if (currentUser.username) {
                user = currentUser;
                $scope.email.recipients.push(user.email);
                $scope.users.push(user);
            } else {
                user.email = currentUser;
                $scope.email.recipients.push(user.email);
                $scope.users.push(user);
            }
            return user;
        };

        $scope.removeRecipient = function (user) {
            var index = $scope.email.recipients.indexOf(user.email);
            if (index >= 0) {
                $scope.email.recipients.splice(index, 1);
            }
        };

        $scope.hide = function () {
            $mdDialog.hide();
        };
        $scope.cancel = function () {
            $mdDialog.cancel();
        };
        (function initController() {
        })();
    }

})();
