angular.module('PhoneBook.services')

.factory('LocalStorage', [
  
  () ->
    
    get: (name) -> JSON.parse localStorage.getItem(name) or null
    put: (name, data) ->
      if name? and data?
        string = if typeof data is 'object' then JSON.stringify(data) else data
        localStorage.setItem name, string
    delete: (name) -> localStorage.removeItem name
    clear: -> localStorage.clear()
  
])
