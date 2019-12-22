
$(function() {
  
  var admin = $("#admin-menu");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showadmin) {admin.show();}
    if (item.hideadmin) {admin.hide();}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if ($("#admin-menu").is(":visible")) {doExit();}
      }
    };
  });
});

function doExit() {
  $("#admin-menu").hide();
  $.post('http://cnr_clans/clanMenu', JSON.stringify({action:"exit"}));
}
