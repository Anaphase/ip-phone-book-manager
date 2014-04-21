angular.module('PhoneBook.controllers')

.controller('Settings', [
  
  '$q'
  '$scope'
  'Settings'
  '$rootScope'
  
  ($q, $scope, Settings, $rootScope) ->
    
    $scope.new_settings = angular.copy $rootScope.PhoneBooks.Settings
    
    $scope.menu_address_placeholder = "#{window.location.origin}#{window.location.pathname}phonebooks/data/xml/#{$scope.new_settings.menu_type}/"
    
    $scope.saveSettings = (new_settings) ->
      
      if new_settings.menu_address.charAt(new_settings.menu_address.length-1) is '/'
        new_settings.menu_address = new_settings.menu_address[0...new_settings.menu_address.length-1]
      
      Settings.saveSettings(new_settings)
        .success (updated_settings) ->
          $rootScope.PhoneBooks.Settings = angular.copy updated_settings
  
])
