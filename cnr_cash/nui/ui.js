
$(function()
{
  
  var wnts = $("#wantedstars");
  
  window.addEventListener('message', function(event)
  {
      var item = event.data;
      
    // Pressing the ESC key with the menu open closes it 
    document.onkeyup = function ( data ) {
      if (data.which == 27) {
        if (rspn.is(":visible")) {Confirm();}
        if (cad.is(":visible")) {doExit();}
      }
    };
  });
});