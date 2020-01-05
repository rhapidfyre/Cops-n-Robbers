
$(function() {
  
  var ammu = $("#ammu-main");
  var wpns = $("#weaponstuff");
  
  window.addEventListener('message', function(event)
  {
      var item = event.data;
      
      if (item.showammu) {
        wpns.empty();
        wpns.html(item.weapons);
        ammu.fadeIn(300);
      }
      
      if (item.ammoct) {
        $("#a"+item.ammoindex).html('+ ' + item.ammoct + ' AMMO');
        $("#b"+item.ammoindex).html('$' + item.ammoprice);
      }
      
      if (item.hideammu) {doExit();}
      
      /*
      This should inclose ALL NUI menus that require user interaction.
      This keeps people from having to reconnect if it gets stuck open
      
      DO NOT CALL doExit() OR ANY $.post
      This should ONLY close menus
      */
      if (item.closemenus) {
        ammu.hide();
      }
      
    // Pressing the ESC key with the menu open closes it 
    document.onkeyup = function ( data ) {
      if (data.which == 27) {
        if (ammu.is(":visible")) {doExit();}
      }
    };
  });
});

function doExit() {
  $.post('http://cnr_ammunation/ammuMenu', JSON.stringify({action: "exit"}));
  $("#ammu-main").fadeOut(1000);
}

function AmmoCount(dir, idx) {
  $.post('http://cnr_ammunation/ammuMenu', JSON.stringify({
    action:"ammoCount",
    weapon:idx,
    more:dir
  }));
}

function BuyWeapon(idx) {
  $.post('http://cnr_ammunation/ammuMenu', JSON.stringify({
    action:"buyWeapon",
    weapon:idx
  }));
}

function BuyAmmo(idx) {
  $.post('http://cnr_ammunation/ammuMenu', JSON.stringify({
    action:"buyAmmo",
    weapon:idx
  }));
}
