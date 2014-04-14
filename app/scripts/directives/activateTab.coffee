angular.module('PhoneBook.directives')

.directive('activateTab', [
  
  '$location'
  
  ($location) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      
      deregister = scope.$on '$routeChangeSuccess', (event, current, previous) ->
        
        tabs = element.find('li')
        page = $location.path().split('/')[1]
        
        for tab in tabs
          $tab = angular.element(tab)
          tab_link = $tab.find('a').attr('href').split('/')[1]
          if tab_link is page
            $tab.addClass("active")
          else
            $tab.removeClass("active")
      
      scope.$on '$destroy', ->
        deregister()
  
])
