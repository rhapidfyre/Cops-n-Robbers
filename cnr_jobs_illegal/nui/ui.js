
$(function() {
  
  var my_menu = $("#menu-main");
  
  window.addEventListener('message', function(event) {
    var item = event.data;
      
    if (item.showmy_menu) {my_menu.show();}
    if (item.hidemy_menu) {my_menu.hide();}
  });
  // Pressing the ESC key with the menu open closes it 
  // If they're viewing member info, it'll close that instead
  document.onkeyup = function (data) {
    if (data.which == 27) {
      if (my_menu.is(":visible")) {doExit();}
    }
  };
});

function doExit() {
  $("#menu-main").hide();
  $.post('http://cnr_resource/thisMenu', JSON.stringify({action:"exit"}));
}
