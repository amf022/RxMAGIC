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

    for( i=0 ; i < data.length ; i++)
    {
        console.log(height)
        console.log(maxHeight)
        if ((height + 40) <= maxHeight) {

            html = html + "<div style='display: table-row' class='"+ ((i % 2 == 0) ? 'odd' : 'even') +"'>"
            for(w = 0; w < keys.length ; w++)
            {
                    html = html + "<div class='base-cell'>"+
                        data[i][keys[w]] +"</div>"
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
    table.innerHTML = html
    document.getElementById('footer').innerHTML = "Showing " + count + " of " + data.length + " Prescriptions"

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
