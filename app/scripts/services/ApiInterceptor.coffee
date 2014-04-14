angular.module('PhoneBook.services')

.factory('ApiInterceptor', [
  
  '$q'
  
  ($q) ->
    
    'request': (config) ->
      if (/\/phonebooks/).test config.url
        config.url = config.url.replace('/phonebooks', 'phonebooks/index.php')
      config or $q.when config
  
])
