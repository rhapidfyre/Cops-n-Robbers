
$(function()
{
    window.addEventListener('message', function(event)
    {
        var item = event.data;
        var buf = $('#wrap');
        buf.find('table').append(
          "<tr><th>ID</th><th>Username</th><th>Wanted Level</th><th>Level</th><th>Latency</th></tr>"
        );
        if (item.meta && item.meta == 'close')
        {
            document.getElementById("plyTable").innerHTML = "";
            $('#wrap').hide();
            return;
        }
        buf.find('table').append(item.text);
        $('#wrap').show();
    }, false);
});