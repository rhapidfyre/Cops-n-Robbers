
$(function() {
  
  var welcome   = $("#motd_bkgd");
  var pedpick   = $("#ped-select");
  
  var admin     = $("#admin-menu");
  var helper    = $("#help-main");
  
  var wnts      = $("#wantedstars");
  var rollerBox = $("#info_box");
  
  let monies = $("#monies");
    
	window.addEventListener('message', function(event) {
		var item = event.data;
  
    if (item.hideallmenus) {
      welcome.hide();
      pedpick.hide();
      admin.hide();
      helper.hide();
      
    } else {
    
      if (item.show)
        $("#"+(item.show)).show();
      
      if (item.hide)
        $("#"+(item.hide)).hide();
      
      if (item.motd)
        $("#changes").find('ul').append(item.motd);
    
      if (item.cashbalance) $("#handcash").html(item.cashbalance);
      if (item.bankbalance) $("#bankcash").html(item.bankbalance);
      
      /* Wanted Stars */
      if (item.crimeoff)  {
        $("#crimefree").fadeIn(200); $("#crimefree").fadeOut(200);
        $("#crimefree").fadeIn(200); $("#crimefree").fadeOut(200);
        $("#crimefree").fadeIn(200);
      }
      if (item.crimeon) {$("#crimefree").fadeOut(1000);}
      
      if (item.nostars) wnts.hide();
      if (item.stars) {
        wnts.show();
        $("#wstar").attr("src", 'stars/' + (item.stars) + '.png');
      }
    
      /* Chat Roller */
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
        
    }
  });
  
  // Pressing the ESC key with the menu open closes it 
  document.onkeyup = function ( data ) {
    
      // ESC
      if ( data.which == 27 ) {
        
        if (welcome.is( ":visible" )) PlayGame();
        if (helper.is(":visible"))    helpExit();
        if (admin.is(":visible"))     adminExit();
        
      }
      
      // DEBUG -
      else if (data.which == 37) ModelSelect(1); // LT ARROW: Prev
      else if (data.which == 39) ModelSelect(2); // RT ARROW: Next
      
  };
	
});


function PlayGame() {$.post('https://cnrobbers/playGame', JSON.stringify("play"));}


// DEBUG - EXTREMELY simple character select method just to get the script going
function ModelSelect(val) {
  if (val == 1)       $.post('https://cnrobbers/modelPick', JSON.stringify("last"));
  else if (val == 2)  $.post('https://cnrobbers/modelPick', JSON.stringify("next"));
  else if (val == 3)  $.post('https://cnrobbers/modelPick', JSON.stringify("random"));
  else                $.post('https://cnrobbers/modelPick', JSON.stringify("choose"));
}

function adminExit() {
  $("#admin-menu").hide();
  $.post('https://cnrobbers/adminMenu', JSON.stringify({action:"exit"}));
}

function helpExit() {
  $("#help-main").hide();
  $.post('https://cnrobbers/helpMenu', JSON.stringify({action:"exit"}));
}

function HelpMenu(val) {
  $(".game-info").hide();
  $("#help"+val).show();
  $("#help-menu>ul>li>button").removeClass('actv');
  $("#btn"+val).addClass('actv');
}
