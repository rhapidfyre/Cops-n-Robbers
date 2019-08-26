
$(function() {
  
  var jail = $("#is-jailed");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showjail) {jail.show();}
    if (item.hidejail) {jail.hide();}
    
    if (item.jailTime) {$("#j-time").html(item.jailTime)};
  });
});
