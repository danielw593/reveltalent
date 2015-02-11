'use strict'

angular.module('app.controllers').controller('RevelTalentCtrl', [
    '$scope'
    'dataStorage'
    ($scope, dataStorage) ->
      $scope.names = dataStorage.names
      $scope.companies = dataStorage.companies
])
