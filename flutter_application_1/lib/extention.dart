extension ConvertToUserName on String{
  String toUserName(){
   var splittedValue= this.split("@");
   String username = splittedValue[0];
   String value = username.length > 10? username.substring(0, 11): username;

   return value;
  }
}