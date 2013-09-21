source = new EventSource('songs/stream')
source.addEventListener 'message',  (e) ->
  song = $.parseJSON(e.data)
  $channels = $('.songs')
  $channel = $channels.find("[data-channel=#{song.channel}]")

  $channel.find('[data-attribute=artist]').text song.artist
  $channel.find('[data-attribute=title]').text song.title

$ ->
  $('.about a').attr('target', '_blank')
