
$(function() {
  
  var clothing = $("#clothing-menu");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showclothing) {clothing.show();}
    if (item.hideclothing) {clothing.hide();}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if ($("#clothing-menu").is(":visible")) {doExit();}
      }
    };
  });
});

function doExit() {
  $("#clothing-menu").hide();
  $.post('http://cnr_clothes/clothingMenu', JSON.stringify({action:"exit"}));
}
