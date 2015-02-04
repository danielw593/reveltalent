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
      info = dataStorage.getCompanies() # FIXME: that can be optimized
      $scope.names = info.names
      $scope.companies = info.companies
      $scope.name = $routeParams.name  
      $scope.company = $scope.findCompany($scope.name)  
])
