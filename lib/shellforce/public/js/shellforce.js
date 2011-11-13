// Event handlers

$(function() {
        $("input[name='requestMethod']").click(function() {
                value = $("input[name='requestMethod']:checked").val();
                if (value == 'POST' || value == 'PATCH') {
                    $("div[id='requestBodyContainer']").show();
                    $("div[id='pathInfo']").show();
                }
                else if (value == 'GET' || value == 'DELETE') {
                    $("div[id='requestBodyContainer']").hide();
                    $("div[id='pathInfo']").show();                    
                }
                else { // 'QUERY' or 'SERACH'
                    $("div[id='requestBodyContainer']").hide();
                    $("div[id='pathInfo']").hide();                    
                }
                
        });
});


$(function() {
        $("input[id='resetButton']").click(function() {
                $("input[name='urlInput']").val('');                
        });
});


$(function() {
        var shellforce_path = [shellforce_current_path, '/services/apexrest', '(root)'];
        var index = 0;
        $("span[name='path']").empty().append(shellforce_current_path);
        $("span[name='path']").click(function() {
                $("span[name='path']").empty().append(shellforce_path[++index % shellforce_path.length]);
                if(index == shellforce_path.length) index = 0;
        });
});


$(function() {
        $("input[id='urlInput']").keypress(function(event) {
                if ((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13)) {
                    $("input[id='executeButton']").click();
                    return false;
                }
        });
});


$(function() {
        $("input[id='executeButton']").click(function() {
                executeShellForce(
                                  (function(path) {return (path.match(/\(root\)/) ? '' : path);})($("span[name='path']").text()),
                                  $("input[name='requestMethod']:checked").val(),
                                  $("input[name='urlInput']").val(),
                                  $("input[name='requestBody']").val()
                                  );
        });
});

$(function() {$("div[class='displayErrors']").hide();});

// Functions that are migrated from REST Explorer in Workbench developed by Ryan Brainard

function toggleCodeViewPort() {
    var container = $("div[id='codeViewPortContainer']");
    var toggler = $("a[id='codeViewPortToggler']");
    
    if (container.css('display') == 'none') {
           container.show();
           toggler.text('Hide Raw Response');
    }
    else {
        container.hide();
        toggler.text('Show Raw Response');
    }
}


function isInt(value){
    if((parseFloat(value) == parseInt(value)) && !isNaN(parseInt(value))){
        return true;
    } else {
        return false;
    }
}


function getKeyLabel(key, nodes) {
	if (!isInt(key)) {
		return key;
	}

	// the following is a list of common values
	// in nodes, which can be used as the label
	// for the key label, if one is missing (i.e. isInt)
	var commonLabels = new Array("name",
								 "Name",
								 "relationshipName",
								 "value",
								 "label",
								 "Id",
								 "errorCode");

	for (var i in commonLabels) {
		if (nodes[key][commonLabels[i]]) {
			return nodes[key][commonLabels[i]];
		}
	}

	return "[Item " + (parseInt(key) + 1) + "]";
}

function buildList(nodes, parent) {
	for (var key in nodes) {
		var li = document.createElement("li");

		if (nodes[key] instanceof Object) {
			li.innerHTML = getKeyLabel(key, nodes);
			li.appendChild(buildList(nodes[key], document.createElement("ul")));
		} else {
			li.innerHTML = key + ": ";
			li.innerHTML += "<strong>" + nodes[key] + "</strong>"
		}

		parent.appendChild(li);
	}

	return parent;
}

function convert(jsonData) {
	var responseListContainer = document.getElementById('responseListContainer');
	responseListContainer.innerHTML = "";
    
	var responseList= document.createElement('ul');
	responseList.id = 'responseList';
	responseList.className = 'treeview';
	responseListContainer.appendChild(buildList(jsonData, responseList));
	ddtreemenu.createTree('responseList', false);
	ddtreemenu.flatten('responseList', 'contract');
}


// Functions that handle requests to shellforce

function getSObjectRecord(url) {
    executeShellForce('', 'GET', url, '');
}


function executeShellForce(path, method, url, body) {
    $("div[class='displayErrors']").hide();
    $("span[id='waitingNotice']").show();

    if (method == 'QUERY' || method == 'SEARCH') {
        path = shellforce_current_path;
    }
    
    // send a POST request to shellforce
    $.ajax({
            type : 'POST',
            url : shellforce_api,
            dataType : 'json',
            data : {'path' : path, 'method' : method, 'url' : url, 'body' : body},
            success : function(response) {
                if (response.error != null) {
                    var message = $("<img src='images/error24.png' width='24' height='24' align='middle' border='0' alt='ERROR :'/><p/><p>" + response.error + "</p>");
                    
                    // Display the error
                    $("div[id='results']").empty();                    
                    $("div[class='displayErrors']").empty().append(message);
                    $("div[class='displayErrors']").show();
                }
                else {
                    // Prepare HTML elements displayed
                    var expand = "javascript:ddtreemenu.flatten('responseList', 'expand');";
                    var expandAll = $('<a href="' + expand + '">Expand All</a>');

                    var contact = "javascript:ddtreemenu.flatten('responseList', 'contact');";
                    var collapseAll = $('<a href="' + contact + '">Collapse All</a>');

                    var showRawResponse = $("<a id='codeViewPortToggler' href='javascript:toggleCodeViewPort();'>Show Raw Response</a>");
                    var responseListContainer = $("<div id='responseListContainer' class='results'><div/>");
                    var responseBody = $("<script type='text/javascript'>convert(" + JSON.stringify(response.clickable, null, " ") + ");</script>");
                    var rawResponseBody = $("<strong>Raw Response</strong><p id='codeViewPort'><br/>"+ JSON.stringify(response.raw, null, " ") + "</p>");
                    var time = $("<br/>Requested in " + response.time + " sec<br/>");

                    // Display the path
                    $("span[name='path']").empty().append(path == '' ? '(root)' : path);

                    // Display the method checked
                    $("input[name='requestMethod']").attr('checked', false);
                    $("input[value='" + method  + "']").attr('checked', true);
                    $("input[value='" + method  + "']").click();

                    // Display the url input
                    $("input[name='urlInput']").val('');
                    $("input[name='urlInput']").val(url);

                    // Put the request body
                    $("input[name='requestBody']").empty().append(body);

                    // Put the results
                    $("div[id='results']").empty().append(expandAll).append(" | ").
                        append(collapseAll).append(" | ").
                        append(showRawResponse).
                        append(responseListContainer).
                        append(responseBody);

                    // Puts the raw response
                    $("div[id='codeViewPortContainer']").empty().append(rawResponseBody);

                    // Display the response time
                    $("div[id='disclaimer']").empty().append(time);
                }
                $("span[id='waitingNotice']").hide();                
            }
    });
}