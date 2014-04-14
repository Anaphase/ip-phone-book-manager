angular.module('PhoneBook.controllers')

.controller('CiscoDirectory', [
  
  '$scope'
  '$filter'
  '$rootScope'
  '$routeParams'
  'resolved_directory'
  
  ($scope, $filter, $rootScope, $routeParams, resolved_directory) ->
    
    $scope.type = 'cisco'
    $scope.directory_id = $routeParams.directory_id
    
    $scope.directory = resolved_directory
    
    if $scope.directory_id
      
      $scope.addDirectoryEntry = ->
        new_entry =
          'Name': ''
          'Telephone': ''
          'Fax': ''
          'Address': ''
          'Email': ''
        $rootScope.PhoneBooks.Cisco.createDirectoryEntry($scope.directory_id, new_entry)
          .success (directory_entry) ->
            $scope.directory.DirectoryEntry.push directory_entry
      
      $scope.deleteDirectoryEntry = (entry) ->
        if confirm("Are you sure you want to delete '#{entry.Name}'?")
          index = $scope.directory.DirectoryEntry.indexOf(entry)
          $rootScope.PhoneBooks.Cisco.deleteDirectoryEntry($scope.directory_id, index)
            .success ->
              $rootScope.PhoneBooks.Cisco.getDirectory($scope.directory_id)
                .success (directory) ->
                  $scope.directory = directory
      
      $scope.saveDirectoryEntry = (entry) ->
        index = $scope.directory.DirectoryEntry.indexOf(entry)
        $rootScope.PhoneBooks.Cisco.saveDirectoryEntry($scope.directory_id, index, entry)
          .success (directory_entry) ->
            entry = directory_entry
      
      $scope.addSoftKeyItem = ->
        new_item =
          'Name': ''
          'URL': ''
          'Position': $scope.directory.SoftKeyItem.length+1
        $rootScope.PhoneBooks.Cisco.createSoftKeyItem($scope.directory_id, new_item)
          .success (soft_key_item) ->
            $scope.directory.SoftKeyItem.push soft_key_item
      
      $scope.deleteSoftKeyItem = (item) ->
        if confirm("Are you sure you want to delete '#{item.Name}'?")
          index = $scope.directory.SoftKeyItem.indexOf(item)
          $rootScope.PhoneBooks.Cisco.deleteSoftKeyItem($scope.directory_id, index)
            .success ->
              $rootScope.PhoneBooks.Cisco.getDirectory($scope.directory_id)
                .success (directory) ->
                  $scope.directory = directory
      
      $scope.saveSoftKeyItem = (item) ->
        index = $scope.directory.SoftKeyItem.indexOf(item)
        $rootScope.PhoneBooks.Cisco.saveSoftKeyItem($scope.directory_id, index, item)
          .success (soft_key_item) ->
            item = soft_key_item
      
      $scope.saveMetadata = (new_title, new_prompt) ->
        
        if new_prompt isnt $scope.directory.Prompt
          $scope.savePrompt(new_prompt).then ->
            if new_title isnt $scope.directory.Title
              $scope.saveTitle(new_title)
        else
          $scope.saveTitle(new_title)
      
      $scope.saveTitle = (new_title) ->
        $rootScope.PhoneBooks.Cisco.saveDirectoryTitle($scope.directory_id, new_title)
          .success (directory) ->
            $scope.directory = directory
            $rootScope.go "/#{$scope.type}/directory/#{$filter('slugify')(directory.Title)}"
      
      $scope.savePrompt = (new_prompt) ->
        $rootScope.PhoneBooks.Cisco.saveDirectoryPrompt($scope.directory_id, new_prompt)
          .success (directory) ->
            $scope.directory = directory
  
])
