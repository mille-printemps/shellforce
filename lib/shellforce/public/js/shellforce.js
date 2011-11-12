// Functions that handle requests to shellforce

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
        $("input[id='executeButton']").click(function() {
                executeShellForce(
                                  (function(path) {return (path.match(/\(root\)/) ? '' : path);})($("span[name='path']").text()),
                                  $("input[name='requestMethod']:checked").val(),
                                  $("input[name='urlInput']").val(),
                                  $("input[name='requestBody']").val()
                                  );
        });
});


var getSObjectRecord = function(url) {
    executeShellForce('', 'GET', url, '');
};


var executeShellForce = function(path, method, url, body) {
    $("span[id='waitingNotice']").show();
    
    // send a POST request to shellforce
    $.ajax({
            type : 'POST',
            url : shellforce_api,
            dataType : 'json',
            data : {'path' : path, 'method' : method, 'url' : url, 'body' : body},
            success : function(response) {
                var expand = "javascript:ddtreemenu.flatten('responseList', 'expand');";
                var expandAll = $('<a href="' + expand + '">Expand All</a>');
                
                var contact = "javascript:ddtreemenu.flatten('responseList', 'contact');";
                var collapseAll = $('<a href="' + contact + '">Collapse All</a>');
                
                var showRawResponse = $("<a id='codeViewPortToggler' href='javascript:toggleCodeViewPort();'>Show Raw Response</a>");
                var responseListContainer = $("<div id='responseListContainer' class='results'><div/>");
                var responseBody = $("<script type='text/javascript'>convert(" + JSON.stringify(response.clickable, null, " ") + ");</script>");
                var rawResponseBody = $("<strong>Raw Response</strong><p id='codeViewPort'><br/>"+ JSON.stringify(response.raw, null, " ") + "</p>");
                var time = $("<br/>Requested in " + response.time + " sec<br/>");

                $("span[name='path']").empty().append(path == '' ? '(root)' : path);
                
                $("input[name='requestMethod']").attr('checked', false);
                $("input[value='" + method  + "']").attr('checked', true);
                
                $("input[name='urlInput']").val('');
                $("input[name='urlInput']").val(path + url);
                
                $("input[name='requestBody']").empty().append(body);                

                $("div[id='results']").empty().append(expandAll).append(" | ").
                    append(collapseAll).append(" | ").
                    append(showRawResponse).
                    append(responseListContainer).
                    append(responseBody);

                $("div[id='codeViewPortContainer']").empty().append(rawResponseBody);

                $("div[id='disclaimer']").empty().append(time);

                $("span[id='waitingNotice']").hide();                
        }
    });
};