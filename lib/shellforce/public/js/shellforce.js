// Functions that handle requests to shellforce

$(function() {
        var shellforce_path = [shellforce_current_path, '/services/apexrest', '/'];
        var index = 0;
        $("span[name='path']").empty().append(shellforce_current_path);
        $("span[name='path']").click(function() {
                $("span[name='path']").empty().append(shellforce_path[++index % shellforce_path.length]);
                if(index == shellforce_path.length) index = 0;
        });
});

$(function() {
        $("input[id='execBtn']").click(function() {
                executeShellForce(
                                  $("span[name='path']").val(),
                                  $('input[name="requestMethod"]:checked').val(),
                                  $('input[name="urlInput"]').val(),
                                  $('input[name="requestBody"]').val()
                                  );
        });
});


var getSObjectRecord = function(url) {
    executeShellForce('/', 'GET', url, '');
};


var executeShellForce = function(path, method, url, body) {
    $("span[id='waitingNotice']").show();
    
    // send a POST request to shellforce
    $.ajax({
            type : 'POST',
            url : shellforce_api,
            dataType : 'text',
            data : {'path' : path, 'method' : method, 'url' : url, 'body' : body},
            success : function(response) {
                var expand = "javascript:ddtreemenu.flatten('responseList', 'expand');";
                var expandAll = $('<a href="' + expand + '">Expand All</a>');
                
                var contact = "javascript:ddtreemenu.flatten('responseList', 'contact');";
                var collapseAll = $('<a href="' + contact + '">Collapse All</a>');
                
                var showRawResponse = $("<a id='codeViewPortToggler' href='javascript:toggleCodeViewPort();'>Show Raw Response</a>");
                var responseListContainer = $("<div id='responseListContainer' class='results'><div/>");
                var responseBody = $("<script type='text/javascript'>convert(" + response + ");</script>");
                var rawResponseBody = $("<strong>Raw Response</strong><p id='codeViewPort'><br/>"+ response + "</p>");

                $("div[id='results']").empty().append(expandAll).append(" | ").
                    append(collapseAll).append(" | ").
                    append(showRawResponse).
                    append(responseListContainer).
                    append(responseBody);

                $("div[id='codeViewPortContainer']").empty().append(rawResponseBody);

                $("span[id='waitingNotice']").hide();                
        }
    });
};