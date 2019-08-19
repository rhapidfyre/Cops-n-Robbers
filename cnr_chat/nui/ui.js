
$(function() {
  
  var chatbox = $("#");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.open)  {clan.show();}
    if (item.close) {clan.hide();}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) { doExit(); } 
      }
    };
  });
});

function doExit() {
  $.post('http://cnr_clans/chatCommand', JSON.stringify("exit"));
}
