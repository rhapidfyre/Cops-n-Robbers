
$(function()
{
  
    var a = $("#a");
  
    window.addEventListener('message', function(event)
    {
        
        var item = event.data;
        if (item.showa) {}
        if (item.hidea) {}
    }, false);
});