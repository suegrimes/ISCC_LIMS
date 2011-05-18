// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function num_date() {
    var mm = new Array("01", "02", "03","04", "05", "06", "07", "08", "09","10", "11", "12");
    var full_date = new Date();
    var curr_date = full_date.getDate();
    var curr_month = full_date.getMonth();
    var curr_year = full_date.getFullYear();
    var num_date = curr_year + "-" + mm[curr_month] + "-" + curr_date;
    return num_date;
}

var $j = jQuery.noConflict(); //use jQuery object with $j and won't conflict with other libraries

var load_date = function(chk_bx_id) {
	$j('#' + chk_bx_id).click(function() {
	    if ( $j('#' + chk_bx_id).is(':checked') ) { 
	        $j('#' + chk_bx_id + '_shipment_attributes_date_received').val(num_date());
        } else { 
	        $j('#' + chk_bx_id + '_shipment_attributes_date_received').val(''); 
        }
	});
};



