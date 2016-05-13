// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require moment
//= require bootstrap-datetimepicker


function reloadTable(section, data, keys, container)
{
    if (container.trim() == "" )
    {
        container = "main";
    }
    var table = document.getElementById(section);
    var html = "";
    var count = 0;
    constant = document.getElementById('heading').offsetHeight + document.getElementById('footer').offsetHeight;
    var height = document.getElementById('heading').offsetHeight + document.getElementById('footer').offsetHeight;
    var maxHeight = window.innerHeight;
    while (table.hasChildNodes()) {
        table.removeChild(table.lastChild);
    }

    patientKeys = Object.keys(data);

    totalCount = 0;
    for (e = 0; e < patientKeys.length;e++ )
    {
        for( i=0 ; i < data[patientKeys[e]].length ; i++)
        {
            if ((height + 40) <= maxHeight) {

                html = html + "<div style='display: table-row' class='"+ ((e % 2 == 0) ? 'odd' : 'even') +"'>"
                for(w = 0; w < keys.length ; w++)
                {
                    html = html + "<div class='base-cell'>"+
                        data[patientKeys[e]][i][keys[w]] +"</div>"
                }
                html += "</div>"
                height += 35;
            }
            else
            {
                break;
            }
            count += 1
        }
        totalCount += data[patientKeys[e]].length;
    }

    table.innerHTML = html
    document.getElementById('footer').innerHTML = "Showing " + count + " of " + totalCount + " Prescriptions"

}

function getData(link)
{
    if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
    }else{// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange=function() {
        if (xmlhttp.readyState==4 && xmlhttp.status==200) {
            var results = xmlhttp.responseText;
            if(results == 'undefined' || results == '' || results == 'null' || results == '"not validate"') {
                return ;
            }else if(results.length > 0){
                handleResults(JSON.parse(results))
            }else{
                //document.getElementById('reporter').innerHTML = "....";
                return ;
            }
        }
    }
    xmlhttp.open("GET",link ,true);
        xmlhttp.send();

}

function hideNotice()
{
    $('#errorModal').removeClass('show');
    $("#errorModal")[0].style["display"] = "none"
}

function getBrowserHeight() {
    var intH = 0;
    var intW = 0;

    if(typeof window.innerWidth  == 'number' ) {
        intH = window.innerHeight;
        intW = window.innerWidth;
    }
    else if(document.documentElement && (document.documentElement.clientWidth || document.documentElement.clientHeight)) {
        intH = document.documentElement.clientHeight;
        intW = document.documentElement.clientWidth;
    }
    else if(document.body && (document.body.clientWidth || document.body.clientHeight)) {
        intH = document.body.clientHeight;
        intW = document.body.clientWidth;
    }

    return { width: parseInt(intW), height: parseInt(intH) };
}

function setLayerPosition(background, main) {
    var shadow = document.getElementById(background);
    var question = document.getElementById(main);

    var bws = getBrowserHeight();
    shadow.style.width = bws.width + "px";
    shadow.style.height = bws.height + "px";

    question.style.left = parseInt((bws.width - 350) / 11);
    question.style.top = parseInt((bws.height - 200) / 15);

    shadow = null;
    question = null;
}

function showLayer(background, main) {
    setLayerPosition(background, main);

    var shadow = document.getElementById(background);
    var question = document.getElementById(main);

    shadow.style.display = "block";
    question.style.display = "block";

    shadow = null;
    question = null;
}

function hideLayer(background,main) {
    var shadow = document.getElementById(background);
    var question = document.getElementById(main);

    shadow.style.display = "none";
    question.style.display = "none";

    shadow = null;
    question = null;
}

function updateNotice(reference, type,action)
{
    if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp=new XMLHttpRequest();
    }else{// code for IE6, IE5
        xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    }
    xmlhttp.onreadystatechange=function() {
        if (xmlhttp.readyState==4 && xmlhttp.status==200) {
            var results = xmlhttp.responseText;
            if(results == 'undefined' || results == '' || results == 'null' || results == 'false') {
                return ;
            }else if(results == 'true'){
                document.getElementById(reference).style.display="none";
            }else{
                //document.getElementById('reporter').innerHTML = "....";
                return ;
            }
        }
    }
    xmlhttp.open("GET","/manage_notice?reference="+reference+ "&type="+type+"&resolution="+action ,true);
    xmlhttp.send();

}

window.onresize = setLayerPosition;