angular.module('PhoneBook.filters')

.filter('newlineToBreakTag', [
  
  () ->
    (text) ->
      text.replace /\n/g, '<br>'
  
])

.filter('slugify', [
  
  () ->
    (string) ->
      string = string.toLowerCase()
      string = string.replace /[^\w ]+/g, ''
      string = string.replace /\ +/g, '-'
      string
  
])
