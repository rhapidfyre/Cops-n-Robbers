
$(function() {
  
  var jail   = $("#is-jailed");
  var ticket = $("#rx_ticket");
  var vehsel = $("#pveh-select");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showjail) {jail.show();}
    if (item.hidejail) {jail.hide();}
      
    if (item.showvehs) {vehsel.show();}
    if (item.hidevehs) {vehsel.hide();}
      
    if (item.showticket) {ticket.show();}
    if (item.hideticket) {ticket.hide();}
    
    if (item.jailTime)   {$("#j-time").html(item.jailTime)};
    if (item.ticketTime) {$("#t-time").html(item.ticketTime)};
    
  });
  
  // Pressing the ESC key with the menu open closes it 
  document.onkeyup = function ( data ) {
    if (vehsel.is(":visible")) {
      if ( data.which == 27 )    {LawVehicle(0);} // ESC
      else if (data.which == 37) {LawVehicle(1);} // LT ARROW: Prev
      else if (data.which == 39) {LawVehicle(2);} // RT ARROW: Next
      else if (data.which == 13) {LawVehicle(0);} // ENTER:    Select
    }
  };
  
});

function LawVehicle(val) {
  if (val == 0) {
    $.post('http://cnr_police/vehicleMenu', JSON.stringify({action:"exit"}));
  } else {
    $.post('http://cnr_police/vehicleMenu', JSON.stringify({
      action:"lawVehicle",
      dir:val
    }));
  }
}

function ToggleExtra(val) {
	$.post('http://cnr_police/vehicleMenu', JSON.stringify({
    action:"toggleExtra",
    num:val
  }));
}