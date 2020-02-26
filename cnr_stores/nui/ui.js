
$(function() {
  
    var a = $("#a");
    
    window.addEventListener('message', function(event)
    {
        
        var item = event.data;
        if (item.showinv) {inv.show();}
        if (item.hideinv) {inv.hide();}
        
    });
        
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if (a.is(":visible")) {CloseMenu();}
      }
    };
        
});


function CloseMenu() {
  $.post('http://cnr_stores/storeMenu', JSON.stringify({
    action:"exit"
  }));
}

