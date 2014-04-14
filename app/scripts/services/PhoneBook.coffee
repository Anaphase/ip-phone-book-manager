angular.module('PhoneBook.services')

.factory('PhoneBook', [
  
  '$http'
  'growl'
  'promiseTracker'
  
  ($http, growl, promiseTracker) ->
    
    class PhoneBook
      
      constructor: (type) ->
        @setType type
        @menu_tracker = promiseTracker()
        @directory_tracker = promiseTracker()
      
      setType: (@type) ->
        switch @type
          when 'cisco'   then @entry_type = 'directory-entry'
          when 'yealink' then @entry_type = 'menu-item'
      
      # menu routes
      getMenu: ->
        $http.get.apply @, [
          "/phonebooks/#{@type}/menu"
          tracker: @menu_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load #{@type} menu: #{d.status_txt}"
      
      getMenuItem: (id) ->
        $http.get.apply @, [
          "/phonebooks/#{@type}/menu/menu-item/#{id}"
          tracker: @menu_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load #{@type} menu item: #{d.status_txt}"
      
      saveMenuTitle: (title) ->
        $http.post.apply @, [
          "/phonebooks/#{@type}/menu/title"
          title
          tracker: @menu_tracker
        ]
        .success => growl.addSuccessMessage "Saved #{@type} menu title"
        .error (d) => growl.addErrorMessage "Could not save #{@type} menu title: #{d.status_txt}"
      
      saveMenuPrompt: (prompt) ->
        return unless @type is 'cisco'
        $http.post.apply @, [
          "/phonebooks/#{@type}/menu/prompt"
          prompt
          tracker: @menu_tracker
        ]
        .success => growl.addSuccessMessage "Saved #{@type} menu prompt"
        .error (d) => growl.addErrorMessage "Could not save #{@type} menu prompt: #{d.status_txt}"
      
      
      # directory routes
      getDirectory: (id) ->
        $http.get.apply @, [
          "/phonebooks/#{@type}/directory/#{id}"
          tracker: @directory_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load #{@type} directory: #{d.status_txt}"
      
      createDirectory: (id, data) ->
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}"
          data
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Created directory"
        .error (d) => growl.addErrorMessage "Could not create #{@type} directory: #{d.status_txt}"
      
      deleteDirectory: (id) ->
        $http.delete.apply @, [
          "/phonebooks/#{@type}/directory/#{id}"
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Deleted directory"
        .error (d) => growl.addErrorMessage "Could not delete #{@type} directory: #{d.status_txt}"
      
      getDirectoryTitle: (id) ->
        $http.get.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/title"
          tracker: @directory_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load #{@type} directory title: #{d.status_txt}"
      
      saveDirectoryTitle: (id, title) ->
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/title"
          title
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Saved directory title"
        .error (d) => growl.addErrorMessage "Could not save #{@type} directory title: #{d.status_txt}"
      
      getDirectoryPrompt: (id) ->
        $http.get.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/prompt"
          tracker: @directory_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load #{@type} directory prompt: #{d.status_txt}"
      
      saveDirectoryPrompt: (id, prompt) ->
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/prompt"
          prompt
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Saved directory prompt"
        .error (d) => growl.addErrorMessage "Could not save #{@type} directory prompt: #{d.status_txt}"
      
      
      # directory entry routes
      getDirectoryEntry: (id, entry_id) ->
        $http.get.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/#{@entry_type}/#{entry_id}"
          tracker: @directory_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load #{@type} directory entry: #{d.status_txt}"
      
      createDirectoryEntry: (id, data) ->
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/#{@entry_type}"
          data
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Created directory entry"
        .error (d) => growl.addErrorMessage "Could not create #{@type} directory entry: #{d.status_txt}"
      
      saveDirectoryEntry: (id, entry_id, data) ->
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/#{@entry_type}/#{entry_id}"
          data
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Saved directory entry"
        .error (d) => growl.addErrorMessage "Could not save #{@type} directory entry: #{d.status_txt}"
      
      deleteDirectoryEntry: (id, entry_id) ->
        $http.delete.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/#{@entry_type}/#{entry_id}"
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage "Deleted directory entry"
        .error (d) => growl.addErrorMessage "Could not delete #{@type} directory entry: #{d.status_txt}"
      
      
      # soft key item routes
      getSoftKeyItem: (id, item_id) ->
        return unless @type is 'cisco'
        $http.get.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/soft-key-item/#{item_id}"
          tracker: @directory_tracker
        ]
        .error (d) => growl.addErrorMessage "Could not load soft key item: #{d.status_txt}"
      
      createSoftKeyItem: (id, data) ->
        return unless @type is 'cisco'
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/soft-key-item"
          data
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage 'Created soft key item'
        .error (d) => growl.addErrorMessage "Could not create soft key item: #{d.status_txt}"
      
      saveSoftKeyItem: (id, item_id, data) ->
        return unless @type is 'cisco'
        $http.post.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/soft-key-item/#{item_id}"
          data
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage 'Saved soft key item'
        .error (d) => growl.addErrorMessage "Could not save soft key item: #{d.status_txt}"
      
      deleteSoftKeyItem: (id, item_id, data) ->
        return unless @type is 'cisco'
        $http.delete.apply @, [
          "/phonebooks/#{@type}/directory/#{id}/soft-key-item/#{item_id}"
          data
          tracker: @directory_tracker
        ]
        .success => growl.addSuccessMessage 'Deleted soft key item'
        .error (d) => growl.addErrorMessage "Could not save soft key item: #{d.status_txt}"
    
])
