
$(function()
{
  
    var wnts = $("#wantedstars");
  
    window.addEventListener('message', function(event)
    {
        var item = event.data;
        $('#wrap').empty();
        if (item.stars) {
          wnts.show();
          $("#wstar").attr("src", 'stars/' + item.stars + '.png');
        }
        if (item.nostars) {wnts.hide();}
        if (item.mostwanted) {
          wnts.show();
          $("#wstar").attr("src", 'stars/11.png');
        }
    }, false);
});