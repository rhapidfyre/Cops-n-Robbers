
$(function() {
  
  var rollerBox   = $("#info_box");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
    
    if (item.newRoller) {
      rollerBox.append(item.newRoller);
      var roller = $("#roll"+(item.idRoller));
      roller.fadeIn(1000);
      $("#rbar"+(item.idRoller)).width('100%');
    }
    
    if (item.timeRoller) {
      
      var roller = $("#roll"+(item.idRoller));
      var rolbar = $("#rbar"+(item.idRoller));
      rolbar.width(item.newWidth+'%');
      
      if (item.newWidth <= 0) {
        roller.find("p").html('&nbsp;');
        roller.animate(
          {height: 0}, 600,
          function() {
            roller.remove();
          }
        );
      }
    }
    
  });
});
