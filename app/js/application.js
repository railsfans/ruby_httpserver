alert("Hello World");

function setCookie(c_name,value,exdays)
{
   var exdate=new Date();
   exdate.setDate(exdate.getDate() + exdays);
   var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
   document.cookie=c_name + "=" + c_value;
}

setCookie('boo', 'boo', 4)
setCookie('boo3', 'boo', 4)
setCookie('boo', 'boo', 4)
