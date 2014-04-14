angular.module('PhoneBook.controllers')

.controller('Navbar', [
  
  '$scope'
  
  ($scope) ->
    
    $scope.$on '$routeChangeSuccess', -> $scope.is_collapsed = yes
    
    $scope.is_collapsed = yes
  
])
