# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
source = new EventSource('songs/foo')
source.addEventListener 'message',  (e) ->
  $('body').append e.data
