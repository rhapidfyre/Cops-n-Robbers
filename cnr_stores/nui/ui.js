
var iSelected = 0;

$(function() {
  
    var store = $("#store-main");
    var buybtn = $("#store-buy");
    
    window.addEventListener('message', function(event)
    {
        
        var item = event.data;
        if (item.showstore) {inv.show();}
        if (item.hidestore) {
          inv.hide();
          buybtn.prop('disabled', true);
          iSelected = 0;
        }
        
        if (item.buyenable)  {buybtn.prop('disabled', false);}
        if (item.buydisable) {buybtn.prop('disabled', true);}
        
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

function Quantity(val) {
  
}