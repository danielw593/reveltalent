'use strict'

angular.module('app.controllers').controller('CompanyCtrl', [
    '$scope'
    'dataStorage'
    '$routeParams'
    ($scope, dataStorage, $routeParams) ->

      $scope.findCompany = (name)->
        for company in $scope.companies
          return company if company.name == name
        return null

      # Initialization
      $scope.names = dataStorage.names
      $scope.companies = dataStorage.companies
      $scope.name = $routeParams.name
      $scope.company = $scope.findCompany($scope.name)
])
