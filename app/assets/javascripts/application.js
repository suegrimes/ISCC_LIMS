// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= superfish

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

