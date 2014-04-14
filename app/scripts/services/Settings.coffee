angular.module('PhoneBook.services')

.factory('Settings', [
  
  '$http'
  'growl'
  'promiseTracker'
  
  ($http, growl, promiseTracker) ->
    
    class Settings
      
      constructor: ->
        @settings_tracker = promiseTracker()
      
      getSettings: ->
        $http.get.apply @, [
          "/phonebooks/settings"
          tracker: @settings_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load settings: #{d.status_txt}"
      
      saveSettings: (settings) ->
        $http.post.apply @, [
          "/phonebooks/settings"
          settings
          tracker: @settings_tracker
        ]
        .success => growl.addSuccessMessage "Saved settings"
        .error (d) => growl.addErrorMessage "Could not save settings: #{d.status_txt}"
    
    new Settings()
    
])
