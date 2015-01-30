function setDimensions()
{
	var menu_h = jQuery('#menubar').height();
	var footer_h = jQuery('#footer').height();
	
	//document.body.style.height = window.innerHeight + 'px';
	document.getElementById('quick-icons').style.height = (window.innerHeight - menu_h) + 'px';
	var h = (window.innerHeight - menu_h - 70);
	jQuery('#products-listing').css('height', h + 'px');
}
jQuery(function()
{
	jQuery('menu ul li').hover(function()
	{
		jQuery(this).find('ul:first').css('display', 'block');
	}, 
	function()
	{
		jQuery(this).find('ul:first').css('display', 'none');
	});
	jQuery(window).resize(setDimensions);
	setDimensions();
});
