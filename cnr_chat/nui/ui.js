
$(function() {
  
  var rollerBox   = $("#info-box");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
    
    if (item.newRoller) {
      $("#info-box").append(item.newRoller);
    }
    
    if (item.timeRoller) {
      var rid = $("#"+(item.idRoller));
      rid.width(item.newWidth);
      if (item.newWidth < 1) {
        rid.animate({right: 100%;}, 500, function() {rid.remove();});
      }
    }
    
  });
});
