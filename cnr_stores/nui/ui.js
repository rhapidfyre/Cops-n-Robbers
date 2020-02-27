
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
    document.onkeyup = function (data) {
      if (data.which == 27) { if (a.is(":visible")) {CloseMenu();} }
    };

});


function CloseMenu() {
  $.post('http://cnr_stores/storeMenu', JSON.stringify({
    action:"exit"
  }));
}


function PurchaseItem(i) {
  let quantity = parseInt($("#store-qty").html());
  $.post('http://cnr_stores/storeMenu', JSON.stringify({
    action:"purchase",
    item:i, qty:quantity
  }));
}


function Quantity(val) {
  let temp = parseInt( $("#store-qty").html() );
  if (dir == 1) { temp = temp + 1; }
  else { temp = temp - 1; }
  if (temp > 10) temp = 10;
  else if (temp < 1) temp = 1;
  $("#store-qty").html(temp);
}