
$(function()
{
    window.addEventListener('message', function(event)
    {
        var item = event.data;
        $('#wrap').empty();
        if (item.exitMenu) {
          console.log('hiding scoreboard');
          $('#wrap').hide();
          return;
        } else {
          console.log('SHOWING scoreboard');
          $("#wrap").append(item.text);
          $('#wrap').show();
        }
    }, false);
});