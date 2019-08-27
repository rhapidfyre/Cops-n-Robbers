
$(function() {
  
  var jail   = $("#is-jailed");
  var ticket = $("#rx_ticket");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showjail) {jail.show();}
    if (item.hidejail) {jail.hide();}
      
    if (item.showticket) {ticket.show();}
    if (item.hideticket) {ticket.hide();}
    
    if (item.jailTime)   {$("#j-time").html(item.jailTime)};
    if (item.ticketTime) {$("#t-time").html(item.ticketTime)};
  });
});
