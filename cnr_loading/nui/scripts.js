
var count = 0;
var thisCount = 0;

const handler = {
  
  startInitFunctionOrder(data)
  {
      count = data.count;
  },
  
  initFunctionInvoking(data)
  {
      document.querySelector('.progressBar').style.left = '0%';
      document.querySelector('.progressBar').style.width = ((data.idx / count) * 100) + '%';
  },
  
  startDataFileEntries(data)
  {
      count = data.count;
  },
  
  onLogLine(data)
  {
      ++thisCount;
      document.querySelector('.progressBar').style.left = '0%';
      document.querySelector('.progressBar').style.width = ((data.idx / count) * 100) + '%';
  }
  
}

window.addEventListener("message", function(e) {
  (handler[e.data.eventName] || function () {})(e.data);
});


function cycleBackgrounds(interval) {
  let index = 0;
  const $imageEls = $('.container .slide'); // Get the images to be cycled.

  setInterval(() => {
    // Get the next index.  If at end, restart to the beginning.
    index = index + 1 < $imageEls.length ? index + 1 : 0

    // Show the next
    $imageEls.eq(index).addClass('show')

    // Hide the previous
    $imageEls.eq(index - 1).removeClass('show')
  }, interval);
}

$(function() {
  cycleBackgrounds(5000);
});
