
$(function() {
	
	var myVar 	= $("#");
	
	window.addEventListener('message', function(event)
	{
		var item = event.data;
		if (item.showmenu) {
			myVar.show();
		}
		if (item.hidemenu) {
			myVar.hide();
		}
	});

    // Pressing the ESC key with the menu open closes it 
    document.onkeyup = function ( data )
	{
        if (data.which == 27) {
			if (myVar.is(':visible'))
			{
				$.post('http://srp_job_delivery/deliveryMenu', JSON.stringify("exit"));
			}
		}
    };
});

function ResetMenu() {
    $( "div" ).each( function( i, obj ) {
        var element = $( this );
        element.hide();
    });
}
