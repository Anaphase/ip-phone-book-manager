angular.module('PhoneBook.controllers')

.controller('YealinkDirectory', [
  
  '$scope'
  '$filter'
  '$rootScope'
  '$routeParams'
  'resolved_directory'
  
  ($scope, $filter, $rootScope, $routeParams, resolved_directory) ->
    
    $scope.directory_type = 'yealink'
    $scope.directory_id = $routeParams.directory_id
    
    $scope.directory = resolved_directory
    
    if $scope.directory_id
      
      $scope.addDirectoryEntry = ->
        new_entry =
          'Prompt': ''
          'URI': ''
        $rootScope.PhoneBooks.Yealink.createDirectoryEntry($scope.directory_id, new_entry)
          .success (menu_item) ->
            $scope.directory.MenuItem.push menu_item
      
      $scope.deleteDirectoryEntry = (entry) ->
        if confirm("Are you sure you want to delete '#{entry.Prompt}'?")
          index = $scope.directory.MenuItem.indexOf(entry)
          $rootScope.PhoneBooks.Yealink.deleteDirectoryEntry($scope.directory_id, index)
            .success (directory) ->
              $rootScope.PhoneBooks.Yealink.getDirectory($scope.directory_id)
                .success (directory) ->
                  $scope.directory = directory
      
      $scope.saveDirectoryEntry = (entry) ->
        index = $scope.directory.MenuItem.indexOf(entry)
        $rootScope.PhoneBooks.Yealink.saveDirectoryEntry($scope.directory_id, index, entry)
          .success (menu_item) ->
            entry = menu_item
      
      $scope.saveMetadata = (new_title) ->
        if new_title isnt $scope.directory.Title
          $rootScope.PhoneBooks.Yealink.saveDirectoryTitle($scope.directory_id, new_title)
            .success (directory) ->
              $scope.directory = directory
              $rootScope.go "/#{$scope.directory_type}/directory/#{$filter('slugify')(directory.Title)}"
  
])
