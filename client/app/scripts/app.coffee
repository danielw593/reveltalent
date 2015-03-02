'use strict';

app = angular.module('app', [
    # Angular modules
    'ngRoute'
    'ngAnimate'

    # 3rd Party Modules
    'ui.bootstrap'
    # 'easypiechart'
    # 'ui.tree'
    # 'ngMap'
    # 'ngTagsInput'
    'angular-loading-bar'

    # Custom modules
    'app.controllers'
    'app.directives'
    # 'app.localization'
    'app.nav'
    'app.ui.ctrls'
    'app.ui.directives'
    'app.ui.services'
    'app.form.validation'
    'app.ui.form.ctrls'
    'app.ui.form.directives'
    # 'app.tables'
    # 'app.task'
    # 'app.chart.ctrls'
    # 'app.chart.directives'
    # 'app.page.ctrls'

    # RevelTalent
])

app.config([
    '$routeProvider'
    ($routeProvider) ->

        routes = [
            'reveltalent'
            'company'
            'dashboard'
            'ui/typography', 'ui/buttons', 'ui/icons', 'ui/grids', 'ui/widgets', 'ui/components', 'ui/boxes', 'ui/timeline', 'ui/nested-lists', 'ui/pricing-tables', 'ui/maps'
            'tables/static', 'tables/dynamic', 'tables/responsive'
            'forms/elements', 'forms/layouts', 'forms/validation', 'forms/wizard'
            'charts/charts', 'charts/flot', 'charts/chartjs'
            'pages/404', 'pages/500', 'pages/blank', 'pages/', 'pages/invoice', 'pages/lock-screen', 'pages/profile', 'pages/signin', 'pages/signup'
            'mail/compose', 'mail/inbox', 'mail/single'
            'tasks/tasks'
        ]

        setRoutes = (route) ->
            url = '/' + route
            config =
                templateUrl: 'views/' + route + '.html'

            $routeProvider.when(url, config)
            return $routeProvider

        routes.forEach( (route) ->
            setRoutes(route)
        )
        $routeProvider
            .when('/', { redirectTo: '/reveltalent'} )
            .when('/company/:name', { templateUrl: 'views/company.html', controller: 'CompanyCtrl'} )
            .when('/404', { templateUrl: 'views/pages/404.html'} )
            .otherwise( redirectTo: '/404' )
])

app.run(["$rootScope", "$http", '$routeParams', ($rootScope, $http, $routeParams) ->
    # TODO: move loadCompanies/findCompany to service
    $rootScope.loadCompanies = ->
      $http.get('http://reveltalent-server.herokuapp.com/companies/index').success((data, status, headers, config) ->
        $rootScope.companies = data.companies
        $rootScope.selectedCompany = $rootScope.findCompany($routeParams.name) if $routeParams.name
        $rootScope.$broadcast 'companiesLoadedEvent', $rootScope.companies, $rootScope.selectedCompany
      ).error((data, status, headers, config) ->
        alert("Failed to load companies\n#{data}")
        # TODO: add nicer error handling
      )

    $rootScope.findCompany = (name)->
      return null unless $rootScope.companies
      for company in $rootScope.companies
        return company if company.name == name
      return null


    # Initialization
    $rootScope.loadCompanies()
])
