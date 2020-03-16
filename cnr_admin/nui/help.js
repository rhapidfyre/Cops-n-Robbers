
$(function() {
  
  var helper = $("#help-menu");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showhelp) {helper.fadeIn(400);}
    if (item.hidehelp) {helper.fadeOut(100);}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if ($("#help-menu").is(":visible")) {doExit();}
      }
    };
  });
});

function doExit() {
  $("#help-menu").hide();
  $.post('http://cnr_admin/helpMenu', JSON.stringify({action:"exit"}));
}
