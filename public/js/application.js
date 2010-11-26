$(function() {
    $("#advanced-toggle").toggle(
        function() {
            $("#advanced").fadeIn("fast");
            $("#advanced-toggle").text("<< Hide advanced");
        },
        function() {
            $("#advanced").fadeOut("fast");
            $("#advanced-toggle").text("Show advanced >>");
        }
    );
    $("#format").bind("change", function() {
        if ("pdf" == $(this).val()) {
            $("#display").val("download");
        }
    })
    /*
    $("#screenshot-form").ajaxForm({
	    target: "#screenshot",
	    beforeSubmit: function() {
	        $("#screenshot").hide();
	    },
	    success: function() { 
            $("#screenshot").fadeIn("fast"); 
        }
	});
	*/
});