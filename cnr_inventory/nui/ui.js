
$(function()
{
  
    var exitListen = false;
    var inv = $("#inv-main");
    
    window.addEventListener('message', function(event)
    {
        
        var item = event.data;
        
        if (item.showinv) {
          inv.show();setTimeout(function() {
            exitListen = true;
          }, 400);
        }
        if (item.hideinv) {
          inv.hide();
          exitListen = false;
        }
        
    });
        
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if (inv.is(":visible")) {CloseMenu();}
      }
      else if (data.which == 112) {
        if (exitListen) {CloseMenu();}
      }
    };
        
});


function CloseMenu() {
  $.post('http://cnr_inventory/inventoryActions', JSON.stringify({
    action:"exit"
  }));
}


function ItemAction(val) {
  $.post('http://cnr_inventory/inventoryActions', JSON.stringify({
    action:"doAction",
    direction:val
  }));
}


/*
function QuantityChange(val) {
  $.post('http://cnr_inventory/inventoryActions', JSON.stringify({
    action:"quantity",
    direction:val
  }));
}
*/


function QuantityChange(dir) {
  let temp = parseInt( $("#qty").val() );
  if (dir == 1) {
    temp = temp + 1;
  } else {
    temp = temp - 1;
  }
  if (temp > 10) temp = 10;
  else if (temp < 1) temp = 1;
  $("#qty").html(temp);
}

