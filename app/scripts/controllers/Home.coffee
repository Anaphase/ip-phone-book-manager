angular.module('PhoneBook.controllers')

.controller('Home', [
  
  '$scope'
  '$filter'
  '$rootScope'
  'resolved_menus'
  
  ($scope, $filter, $rootScope, resolved_menus) ->
    
    $scope.cisco_menu = resolved_menus.cisco
    $scope.yealink_menu = resolved_menus.yealink
    
    $scope.addDirectory = (type) ->
      
      name = prompt 'Enter the new directory name:'
      
      if type is 'cisco'
        name_key  = 'Name'
        phonebook = 'Cisco'
        menu_name = 'cisco_menu'
        new_directory =
          Title: name
          Prompt: 'Please select a contact'
          DirectoryEntry: []
          SoftKeyItem: [
              Name: 'Dial'
              URL: 'SoftKey:Dial'
              Position: '1'
            , 
              Name: 'Menu'
              URL: "#{$rootScope.PhoneBooks.Settings.menu_address}/menu.xml"
              Position: '2'
            , 
              Name: 'Exit'
              URL: 'SoftKey:Exit'
              Position: '3'
          ]
      else
        name_key  = 'Prompt'
        phonebook = 'Yealink'
        menu_name = 'yealink_menu'
        new_directory =
          Title: name
          MenuItem: []
      
      if name?
        
        directory_id = $filter('slugify')(name)
        
        $rootScope.PhoneBooks[phonebook].createDirectory(directory_id, new_directory)
          .success ->
            $rootScope.PhoneBooks[phonebook].getMenu()
              .success (menu) ->
                $scope[menu_name] = menu
    
    $scope.deleteDirectory = (type, directory) ->
      
      if type is 'cisco'
        name_key  = 'Name'
        phonebook = 'Cisco'
        menu_name = 'cisco_menu'
      else
        name_key  = 'Prompt'
        phonebook = 'Yealink'
        menu_name = 'yealink_menu'
      
      directory_id = $filter('slugify')(directory[name_key])
      
      if confirm("Are you sure you want to delete '#{directory[name_key]}'?")
        $rootScope.PhoneBooks[phonebook].deleteDirectory(directory_id)
          .success ->
            $rootScope.PhoneBooks[phonebook].getMenu()
              .success (menu) ->
                $scope[menu_name] = menu
    
    $scope.saveDirectoryTitle = (type, old_title, new_title) ->
      
      directory_id = $filter('slugify')(old_title)
      
      if type is 'cisco'
        phonebook = 'Cisco'
        menu_name = 'cisco_menu'
      else
        phonebook = 'Yealink'
        menu_name = 'yealink_menu'
      
      $rootScope.PhoneBooks[phonebook].saveDirectoryTitle(directory_id, new_title)
        .success ->
          $rootScope.PhoneBooks[phonebook].getMenu()
            .success (menu) ->
              $scope[menu_name] = menu
    
    $scope.saveMetadata = (type, new_title, new_prompt) ->
      
      if type is 'cisco'
        phonebook = 'Cisco'
        menu_name = 'cisco_menu'
      else
        phonebook = 'Yealink'
        menu_name = 'yealink_menu'
      
      if new_title isnt $scope[menu_name].Title
        $rootScope.PhoneBooks[phonebook].saveMenuTitle(new_title)
          .success (menu) ->
            $scope[menu_name] = menu
      
      if type is 'cisco' and new_prompt isnt $scope[menu_name].Prompt
        $rootScope.PhoneBooks[phonebook].saveMenuPrompt(new_prompt)
          .success (menu) ->
            $scope[menu_name] = menu
  
])
