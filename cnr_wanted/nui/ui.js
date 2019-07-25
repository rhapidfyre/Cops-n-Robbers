
$(function()
{
  
    var wnts = $("#wantedstars");
  
    window.addEventListener('message', function(event)
    {
        var item = event.data;
        $('#wrap').empty();
        if (item.stars) {
          wnts.show();
          $("#wstar").attr("src", 'stars/' + item.stars + '.gif');
        }
        if (item.nostars) {wnts.hide();}
        if (item.mostwanted) {
          wnts.show();
          console.log('MW: stars/11.gif');
          $("#wstar").attr("src", 'stars/11.gif');
        }
    }, false);
});