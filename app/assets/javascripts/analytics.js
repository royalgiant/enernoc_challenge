$(document).ready(function(){
	$('form.import').submit(function(e) {
	   	var $this = $(this);
	   	var $input =  $this.find('input#file').val();
		if($input == 0) {
		  alert ("Choose a file first!");
		  return false; 
		  e.preventDefault(); 
		}    
	});
});