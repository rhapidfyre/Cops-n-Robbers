
var pgNumber  = 1;
var fNumber   = 0;
var parentOne = 0;
var parentTwo = 21;

$(function() {
	
  var welcome = $("#motd_bkgd");
  
  var design  = $("#designer");
  var parents = $("#dsg_parents");
  var overlay = $("#dsg_overlays");
  var feature = $("#dsg_feats");
  var slider  = $("#feat_slide");
  var clothes = $("#dsg_clothes");

	window.addEventListener('message', function(event) {
		
		var item = event.data;
  
      if (item.showwelcome) {welcome.fadeIn(1000);}
      if (item.hidewelcome) {welcome.fadeOut(200);}
      if (item.motd) {$("#changes").find('ul').append(item.motd);}
      if (item.hideready) {
        $("#letsplay").removeClass('ntrdy');
        $("#letsplay").click(PlayGame);
        $("#letsplay").html('PLAY!');
      }
      
      if (item.opendesigner) {
        console.log('Opening Designer');
        design.show();
        parents.show();
      }
      if (item.nodesigner) {
        console.log('Closing Designer');
        design.hide();
        HideSubMenus();
      }
      // Emergency Close-All that all scripts must have
      if (item.hideallmenus) {
        console.log('Emergency Closure');
        welcome.hide();
        design.hide();
        HideSubMenus();
      }
      if (item.getParents) {
        var likeness = document.getElementById("bodyslide").value
        $.post('http://cnr_charcreate/heritage', JSON.stringify({
          action:"changeParent",
          pOne:parentOne,
          pTwo:parentTwo,
          similarity:likeness
        }));
      }
  });
  
  // Pressing the ESC key with the menu open closes it 
  document.onkeyup = function ( data ) {
      if ( data.which == 27 ) {
          if ( welcome.is( ":visible" ) ) {PlayGame();}
      }
  };
	
});


function HideSubMenus() {
  $("#dsg_parents").hide();
  $("#dsg_overlays").hide();
  $("#dsg_feats").hide();
  $("#feat_slide").hide();
  $("#dsg_clothes").hide();
}


function PlayGame() {
	$.post('http://cnr_charcreate/playGame', JSON.stringify("play"));
}


function PageChange(dir) {
  if (dir == 1) {
    pgNumber += 1;
    if (pgNumber > 4) {pgNumber = 1;}
  }
  else {
    pgNumber -= 1;
    if (pgNumber < 1) {pgNumber = 4;}
  }
  HideSubMenus();
  if (pgNumber == 1)      {$("#dsg_parents").show();}
  else if (pgNumber == 2) {$("#dsg_overlays").show();}
  else if (pgNumber == 3) {$("#dsg_feats").show();}
  else if (pgNumber == 4) {$("#dsg_clothes").show();}
}


function faceConfirm() {
  $("#feat_slide").hide();
  $("#dsg_feats").show();
  /*
	$.post('http://cnr_charcreate/faceFeatures', JSON.stringify({
    action:"confirm"
  }));
  */
}


function Parent(pVal, dVal) {
  if (pVal == 1) { // Daddy
    if (dVal == 1) {
      parentOne += 1;
      if (parentOne > 44)  {parentOne =  0;}
      if (parentOne == 21) {parentOne = 22;}
      if (parentOne > 24)  {parentOne = 42;}
    }
    else {
      parentOne -= 1;
      if (parentOne < 0)   {parentOne = 44;}
      if (parentOne == 21) {parentOne = 22;}
      if (parentOne > 24 && parentOne < 42)
          {parentOne = 23;}
    }
  }
  else { // Mommy
    if (dVal == 1) {
      parentTwo += 1;
      if (parentTwo > 45)  {parentTwo =  0;}
      if (parentTwo < 21)  {parentTwo = 21;}
      if (parentTwo < 25 && parentTwo != 21) 
          {parentTwo = 25;}
    }
    else {
      parentTwo -= 1;
      if (parentTwo < 21)  {parentTwo = 45;}
      if (parentTwo == 44) {parentTwo = 41;}
      if (parentTwo < 25)  {parentTwo = 21;}
    }
  }
	var likeness = document.getElementById("bodyslide").value
  $("#dadpic").attr('src', 'pics/'+parentOne+'.png');
  $("#mompic").attr('src', 'pics/'+parentTwo+'.png');
  console.log('parentOne['+parentOne+'] parentTwo['+parentTwo+']')
	$.post('http://cnr_charcreate/heritage', JSON.stringify({
    action:"changeParent",
    pOne:parentOne,
    pTwo:parentTwo,
    similarity:likeness
  }));
}


function SelectGender(val) {
  var gender = "mp_m_freemode_01";
  if (val == 1) { gender = "mp_f_freemode_01"; }
  $.post('http://cnr_charcreate/heritage', JSON.stringify({
    action:"gender",
    sex:gender
  }));
}


function ChangeSlider(){
	var likeness = document.getElementById("bodyslide").value;
	$.post('http://cnr_charcreate/heritage', JSON.stringify({
    action:"changeParent",
    pOne:parentOne,
    pTwo:parentTwo,
    similarity:likeness
  }));
}


function SetOverlay(olay, dir) {
  $.post('http://cnr_charcreate/doOverlays', JSON.stringify({
  	action:"setOverlay",
  	ovr:olay,
    direction:dir
  }));
}

function EyeColor(dir) {
  $.post('http://cnr_charcreate/doOverlays', JSON.stringify({
  	action:"eyeColor",
    direction:dir
  }));
}

function HairStyle(dir) {
  $.post('http://cnr_charcreate/doOverlays', JSON.stringify({
  	action:"hairStyle",
    direction:dir
  }));
}

function HairColor(cVal, dir) {
  if (cVal == 1) {
    $.post('http://cnr_charcreate/doOverlays', JSON.stringify({
      action:"hairHighlight",
      direction:dir
    }));
  }
  else {
    $.post('http://cnr_charcreate/doOverlays', JSON.stringify({
      action:"hairColor",
      direction:dir
    }));
  }
}

function faceFeat(val) {
  fNumber = val;
  $("#dsg_feats").hide();
  $("#feat_slide").show();
}

function ChangeFeature() {
  var sliderVal = document.getElementById("featslide").value;
  $.post('http://cnr_charcreate/facialFeatures', JSON.stringify({
    action:"setFeature",
    fNum:fNumber,
    sVal:sliderVal
  }));
}

function ChooseOutfit(gender, outfit) {
  $.post('http://cnr_charcreate/clothingOptions', JSON.stringify({
    action:"setOutfit",
    sex:gender,
    cNum:outfit
  }));
}

function SubmitPlayer() {
  $("#cnfm").show();
  $("#c_reset").hide();
  $("#c_approve").show();
}

function RevertAll() {
  $("#cnfm").show();
  $("#c_approve").hide();
  $("#c_reset").show();
}

function DoReset(val) {
  if (val == 1) {
    $.post('http://cnr_charcreate/finishPlayer', JSON.stringify("reset"));
  }
  $("#cnfm").hide();
  $("#c_approve").hide();
  $("#c_reset").hide();
}

function DoConfirm(val) {
  if (val == 1) {
    $.post('http://cnr_charcreate/finishPlayer', JSON.stringify("apply"));
  }
  $("#cnfm").hide();
  $("#c_approve").hide();
  $("#c_reset").hide();
}



