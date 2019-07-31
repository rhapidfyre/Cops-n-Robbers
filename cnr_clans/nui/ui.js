
$(function() {
  
  var clan = $("#clan_main");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.open)  {clan.show();}
    if (item.close) {clan.hide();}
    
    if (item.hideallmenus) {
      clan.hide();
    }
    
    if (item.clans) {
      $("#clan_list").show();
      $("#clan_list tbody").empty();
      $("#clan_list tbody").append(item.clans);
    }
    
    if (item.roster) {
      HideAllSubmenus();
      $("#clan_roster").show();
      $("#clan_roster tbody").empty();
      $("#clan_roster tbody").append(item.roster);
    }
    
    if(item.showload) {
      HideAllSubmenus();
      $("#load_wait").show();
    }
    
    if(item.hideload) {$("#load_wait").hide();}
    
    // Pressing the ESC key with the menu open closes it 
    document.onkeyup = function (data) {
      if (data.which == 27) { if (clan.is(":visible")) {doExit();} }
    };
  });
});

function doExit() {
  $("#clan_main").hide();
  $.post('http://cnr_clans/clanMenu', JSON.stringify({action:"exit"}));
}

function HideAllSubmenus() {
  $("#clan_roster").hide();
  $("#creator").hide();
  $("#pending").hide();
  $("#load_wait").hide();
}

function ViewRoster(val) {
  console.log('DEBUG - ViewRoster('+val+')');
  $("#load_wait").show();
  $.post('http://cnr_clans/clanMenu', JSON.stringify({
    action:"roster",
    clanNumber:val
  }));
  console.log('DEBUG - ViewRoster() Done.');
}