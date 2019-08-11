
$(function() {
  
  var clan = $("#clan_main");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.open)  {clan.show();}
    if (item.close) {clan.hide();}
    
    if (item.hideallmenus) {
      clan.hide();
      $("#member_info").hide();
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
    
    if(item.showmember) {
      $("#member_info").show();
      $("#member_deets").find('h3').html(item.nm);
      $("#member_deets").find('h5').html(
        'Civ Level: ' + item.clv + '<br>Cop Level: ' + item.leo
      );
    }
    
    if(item.hidemember) {$("#member_info").hide();}
    if(item.hideload)   {$("#load_wait").hide();}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if ($("#member_info").is(":visible")) {
          CloseMember();
        } else {
          if (clan.is(":visible")) {doExit();}
        }
      }
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
  $("#member_info").hide();
}

function ViewRoster(val) {
  $("#load_wait").show();
  $.post('http://cnr_clans/clanMenu', JSON.stringify({
    action:"roster",
    clanNumber:val
  }));
}

function ViewMember(val) {
  $.post('http://cnr_clans/clanMenu', JSON.stringify({
    action:"memberInfo",
    member:val
  }));
}

function MakeLeader() {
  $.post('http://cnr_clans/clanMenu', JSON.stringify({action:"newLeader"}));
}

function ClanRemove() {
  $.post('http://cnr_clans/clanMenu', JSON.stringify({action:"remove"}));
}

function CloseMember() {$("#member_info").hide();}

