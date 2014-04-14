angular.module('PhoneBook.controllers')

.controller('Settings', [
  
  '$q'
  '$scope'
  'Settings'
  '$rootScope'
  'resolved_settings'
  
  ($q, $scope, Settings, $rootScope, resolved_settings) ->
    
    $scope.settings = resolved_settings
    $scope.menu_address_placeholder = window.location.origin + window.location.pathname
    
    $scope.saveSettings = (settings) ->
      
      if $scope.settings.menu_address.charAt($scope.settings.menu_address.length-1) is '/'
        $scope.settings.menu_address = $scope.settings.menu_address[0...$scope.settings.menu_address.length-1]
      
      Settings.saveSettings(settings)
  
])
