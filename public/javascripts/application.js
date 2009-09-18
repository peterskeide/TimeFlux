// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function enable_disable_year() {
  var repeat = document.getElementById("holiday_repeat").checked;
  document.getElementById("holiday_date_1i").disabled=repeat;
  document.getElementById("holiday_date_1i_").disabled=!repeat;
}

function toggle_tag_select(tag_id) {
    a = document.getElementById(tag_id);
    if (a.getAttribute('class') == 'false_tag') {set_to = true} else {set_to = false};
    a.setAttribute('class', set_to + '_tag');
    hidden = document.getElementById('tags_' + tag_id);
    hidden.setAttribute('value', set_to);
}

