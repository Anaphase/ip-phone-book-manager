'use strict'

angular.module('PhoneBook.filters', [])
angular.module('PhoneBook.services', [])
angular.module('PhoneBook.directives', [])
angular.module('PhoneBook.controllers', [])

angular.module('PhoneBook', [
  
  # Angular modules
  'ngRoute'
  'ngAnimate'
  'ngSanitize'
  'ngResource'
  
  # PhoneBook modules
  'PhoneBook.filters'
  'PhoneBook.services'
  'PhoneBook.directives'
  'PhoneBook.controllers'
  
  # siml-angular-brunch modules
  'PhoneBook.templates'
  
  # UI Bootstrap modules
  'ui.bootstrap.collapse'
  
  # Miscellaneous modules
  'angular-growl'
  'ajoslin.promise-tracker'
  
])

.config([
  
  'growlProvider'
  '$httpProvider'
  '$routeProvider'
  
  (growlProvider, $httpProvider, $routeProvider) ->
    
    growlProvider.globalTimeToLive 5000
    
    $httpProvider.interceptors.push 'ApiInterceptor'
    
    resolved_settings = [
      
      '$q'
      'Settings'
      '$rootScope'
      
      ($q, Settings, $rootScope) ->
        deferred = $q.defer()
        Settings.getSettings()
          .success (settings) ->
            $rootScope.PhoneBooks.Settings = settings
            deferred.resolve(settings)
          .error -> deferred.reject()
        deferred.promise
      
    ]
    
    $routeProvider
      
      .when '/',
        controller: 'Home'
        templateUrl: 'templates/home'
        resolve:
          resolved_menus: [
            
            '$q'
            '$route'
            '$rootScope'
            
            ($q, $route, $rootScope) ->
              cisco_deferred = $q.defer()
              yealink_deferred = $q.defer()
              
              $rootScope.PhoneBooks.Cisco.getMenu()
                .success (menu) -> cisco_deferred.resolve(menu)
                .error -> cisco_deferred.reject()
              $rootScope.PhoneBooks.Yealink.getMenu()
                .success (menu) -> yealink_deferred.resolve(menu)
                .error -> yealink_deferred.reject()
              
              $q.all
                cisco: cisco_deferred.promise
                yealink: yealink_deferred.promise
            
          ]
          resolved_settings: resolved_settings
      
      .when '/cisco/directory/:directory_id',
        controller: 'CiscoDirectory'
        templateUrl: 'templates/directory'
        resolve:
          resolved_directory: [
            
            '$q'
            '$route'
            '$rootScope'
            
            ($q, $route, $rootScope) ->
              deferred = $q.defer()
              $rootScope.PhoneBooks.Cisco.getDirectory($route.current.params.directory_id)
                .success (directory) -> deferred.resolve(directory)
                .error -> deferred.reject()
              deferred.promise
            
          ]
      
      .when '/yealink/directory/:directory_id',
        controller: 'YealinkDirectory'
        templateUrl: 'templates/directory'
        resolve:
          resolved_directory: [
            
            '$q'
            '$route'
            '$rootScope'
            
            ($q, $route, $rootScope) ->
              deferred = $q.defer()
              $rootScope.PhoneBooks.Yealink.getDirectory($route.current.params.directory_id)
                .success (directory) -> deferred.resolve(directory)
                .error -> deferred.reject()
              deferred.promise
            
          ]
      
      .when '/settings',
        controller: 'Settings'
        templateUrl: 'templates/settings'
        resolve:
          resolved_settings: resolved_settings
      
      .otherwise
        redirectTo: '/'
  
])

.run([
  
  'App'
  'Settings'
  'PhoneBook'
  '$location'
  '$rootScope'
  
  (App, Settings, PhoneBook, $location, $rootScope) ->
    
    document.title = App.name
    
    $rootScope.App = App
    
    $rootScope.go = (route) -> $location.path route
    
    Settings.getSettings().success (settings) ->
      $rootScope.PhoneBooks.Settings = settings
    
    $rootScope.PhoneBooks =
      Cisco: new PhoneBook('cisco')
      Yealink: new PhoneBook('yealink')
    
    FastClick.attach(document.body)
  
])
