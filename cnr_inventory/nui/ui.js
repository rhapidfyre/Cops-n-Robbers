
var iSelected = 0;
var iAction   = "i";

$(function() {
  
    var exitListen = false;
    var inv   = $("#inv-main");
    var items = $("#inv-items");
    
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
        if (item.invupdate) {
          items.empty();
          items.html(item.invupdate);
          // On update, reset item selector
          $("#inv-items").find("*").removeClass("highlight");
          iSelected = 0;
          iAction   = "i";
        }
        
    });
        
    // Pressing the ESC key with the menu open closes it
    // Also checks for F1 press to close the menu as well
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if (inv.is(":visible")) {CloseMenu();}
      }
      else if (data.which == 112) {
        if (exitListen) {CloseMenu();}
      }
    };
    
    // Handle item highlighting
    $(document).on('click', '.item', function() {
      let ele = $(this).attr('id');
      let val = ele.substring(1, ele.length);
      let act = ele.substring(0, 1);
      $("#inv-items").find("*").removeClass("highlight");
      $(this).addClass("highlight");
      iSelected = parseInt(val);
      iAction   = act;
    });
        
});


function CloseMenu() {
  $.post('http://cnr_inventory/inventoryActions', JSON.stringify({
    action:"exit"
  }));
}


function ItemAction(val) {
  $.post('http://cnr_inventory/inventoryActions', JSON.stringify({
    action:"doAction",
    item:iSelected,
    actn:iAction,
    quantity:$("#qty").html(),
    trigger:val
  }));
}


function QuantityChange(dir) {
  let temp = parseInt( $("#qty").html() );
  if (dir == 1) { temp = temp + 1; }
  else { temp = temp - 1; }
  if (temp > 10) temp = 10;
  else if (temp < 1) temp = 1;
  $("#qty").html(temp);
}

