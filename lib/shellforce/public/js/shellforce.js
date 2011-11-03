// Functions that handles requests to shellforce

$(function(){
        $('input#execBtn').click(executeShellForce);
        return false;
});

var executeShellForce = function() {
    $("span[id='waitingNotice']").show();
    
    // parse parameters
    var method = $('input[name="requestMethod"]:checked').val();
    var url = $('input[name="urlInput"]').val();
    var body = $('input[name="requestBody"]').val();

    // send a POST request to shellforce
    $.ajax({
            type : 'POST',
            url : shellforce_api,
            dataType : 'text',
            data : {'method' : method, 'url' : url, 'body' : body},
            success : function(response) {
                var expand = "javascript:ddtreemenu.flatten('responseList', 'expand');";
                var expandAll = $('<a href="' + expand + '">Expand All</a>');
                
                var contact = "javascript:ddtreemenu.flatten('responseList', 'contact');";
                var collapseAll = $('<a href="' + contact + '">Collapse All</a>');
                
                var showRawResponse = $("<a id='codeViewPortToggler' href='javascript:toggleCodeViewPort();'>Show Raw Response</a>");
                var responseListContainer = $("<div id='responseListContainer' class='results'><div/>");
                var responseBody = $("<script type='text/javascript'>convert(" + response + ");</script>");
                var rawResponseBody = $("<strong>Raw Response</strong><p id='codeViewPort'><br/>"+ response + "</p>");

                $("span[id='waitingNotice']").hide();

                $("div[id='results']").empty().append(expandAll).append(" | ").
                    append(collapseAll).append(" | ").
                    append(showRawResponse).
                    append(responseListContainer).
                    append(responseBody);

                $("div[id='codeViewPortContainer']").empty().append(rawResponseBody);
        }
    });
};