
$(function()
{

  let monies = $("#monies");

  window.addEventListener('message', function(event)
  {
      var item = event.data;

      if (item.showmoney) { monies.fadeIn(400); }
      if (item.hidemoney) { monies.hide(); }

      if (item.cashbalance) {
        $("#handcash").html(item.cashbalance);
      }

      if (item.bankbalance) {
        $("#bankcash").html(item.bankbalance);
      }

    /* Pressing the ESC key with the menu open closes it
    document.onkeyup = function ( data ) {
      if (data.which == 27) {

      }
    };
    */
  });
});