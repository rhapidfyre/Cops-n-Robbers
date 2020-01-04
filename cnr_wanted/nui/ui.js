
$(function()
{
  
    var wnts = $("#wantedstars");
  
    window.addEventListener('message', function(event)
    {
        
        var item = event.data;
        if (item.crimeoff)  {
          $("#crimefree").fadeIn(600); $("#crimefree").fadeOut(600);
          $("#crimefree").fadeIn(600); $("#crimefree").fadeOut(600);
          $("#crimefree").fadeIn(600);
        }
        if (item.crimeon) {$("#crimefree").fadeOut(200);}
        
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