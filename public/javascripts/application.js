// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function enable_disable_year() {
  var repeat = document.getElementById("holiday_repeat").checked;
  document.getElementById("holiday_date_1i").disabled=repeat;
  document.getElementById("holiday_date_1i_").disabled=!repeat;
}