
$(function() {
  
  var admin = $("#admin-menu");
  var helper = $("#help-main");
  
  window.addEventListener('message', function(event)
  {
    var item = event.data;
      
    if (item.showadmin) {admin.show();}
    if (item.hideadmin) {admin.hide();}
    
    if (item.showhelp) {helper.fadeIn(400);}
    if (item.hidehelp) {helper.fadeOut(100);}
    
    // Pressing the ESC key with the menu open closes it 
    // If they're viewing member info, it'll close that instead
    document.onkeyup = function (data) {
      if (data.which == 27) {
        if ($("#help-main").is(":visible")) {helpExit();}
        if ($("#admin-menu").is(":visible")) {adminExit();}
      }
    };
  });
});

function adminExit() {
  $("#admin-menu").hide();
  $.post('http://cnr_admin/adminMenu', JSON.stringify({action:"exit"}));
}

function helpExit() {
  $("#help-main").hide();
  $.post('http://cnr_admin/helpMenu', JSON.stringify({action:"exit"}));
}

function HelpMenu(val) {
  $(".game-info").hide();
  $("#help"+val).show();
  $("#help-menu>ul>li>button").removeClass('actv');
  $("#btn"+val).addClass('actv');
}