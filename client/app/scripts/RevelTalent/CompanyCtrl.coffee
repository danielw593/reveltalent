'use strict'

angular.module('app.controllers').controller('CompanyCtrl', [
    '$scope'
    '$routeParams'
    ($scope, $routeParams) ->

      $scope.$on 'companiesLoadedEvent', (event, companies, selectedCompany)->
          $scope.company = selectedCompany

      # Initialization
      $scope.company = $scope.findCompany($routeParams.name)
])
