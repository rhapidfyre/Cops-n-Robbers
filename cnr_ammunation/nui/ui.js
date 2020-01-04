
$(function()
{
  
  var ammu = $("#ammu-main");
  
  window.addEventListener('message', function(event)
  {
      var item = event.data;
      
      if (item.showammu) {ammu.fadeIn(300);}
      if (item.hideammu) {doExit();}
      
    // Pressing the ESC key with the menu open closes it 
    document.onkeyup = function ( data ) {
      if (data.which == 27) {
        if (ammu.is(":visible")) {doExit();}
      }
    };
  });
});

function doExit() {
  $.post('http://cnr_ammunation/ammuMenu', JSON.stringify({action: "exit"}));
  $("#ammu-main").fadeOut(1000);
}