
var iSelected = 0;

$(function() {
  
    var store = $("#store-main");
    var buybtn = $("#store-buy");
    
    window.addEventListener('message', function(event)
    {
        
        var item = event.data;
        if (item.showstore) {
          store.show();
          $("#store-cont h3").html(item.storetitle);
          $("#store-iname").val('Please Select an Item');
          $("#store-price").val('-');
        }
        if (item.hidestore) {
          store.hide();
          buybtn.prop('disabled', true);
          $("#store-qty").val('1');
          iSelected = 0;
        }
        
        if (item.iteminfo) {
          $("#store-iname").val(item.itemName);
          $("#store-price").val(item.itemCost);
        }
        
        if (item.buyenable)  {buybtn.prop('disabled', false);}
        if (item.buydisable) {buybtn.prop('disabled', true);}
        
        if (item.storeitems) {
          $("#store-items").empty();
          $("#store-items").html(item.storeitems);
        }
        
    });
        
    // Pressing the ESC key with the menu open closes it 
    document.onkeyup = function (data) {
      if (data.which == 27) { if (store.is(":visible")) {CloseMenu();} }
    };

    
    // Handle item highlighting
    $(document).on('click', '.item', function() {
      let ele = $(this).attr('id');
      let val = ele.substring(1, ele.length);
      $("#store-items").find("*").removeClass("highlight");
      $(this).addClass("highlight");
      iSelected = parseInt(val);
      $.post('http://cnr_stores/storeMenu', JSON.stringify({
        action:"viewItem",
        iNum:iSelected
      }));
    });
});


function CloseMenu() {
  $.post('http://cnr_stores/storeMenu', JSON.stringify({
    action:"exit"
  }));
}


function PurchaseItem() {
  let quantity = parseInt($("#store-qty").val());
  $.post('http://cnr_stores/storeMenu', JSON.stringify({
    action:"purchase",
    item:iSelected, qty:quantity
  }));
}


function Quantity(dir) {
  let temp = parseInt( $("#store-qty").val() );
  if (dir == 1) temp = temp + 1; 
  else temp = temp - 1;
  if (temp > 10) temp = 10;
  else if (temp < 1) temp = 1;
  $("#store-qty").val(temp);
}