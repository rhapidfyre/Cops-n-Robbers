
$(function() {
  
  var vehicles = $("#vehicle-menu");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showvehicles) {vehicles.show();}
    if (item.hidevehicles) {vehicles.hide();}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if ($("#vehicles-menu").is(":visible")) {doExit();}
      }
    };
  });
});

function doExit() {
  $("#vehicles-menu").hide();
  $.post('http://cnr_clothes/vehicleMenu', JSON.stringify({action:"exit"}));
}
