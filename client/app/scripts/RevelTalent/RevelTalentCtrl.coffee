'use strict'

angular.module('app.controllers').controller('RevelTalentCtrl', [
    '$scope'
    'dataStorage'
    ($scope, dataStorage) ->
      info = dataStorage.getCompanies()
      $scope.names = info.names
      $scope.companies = info.companies

])
