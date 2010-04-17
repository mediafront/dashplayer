var nodeSpinner:MovieClip = null;
var playlistSpinner:MovieClip = null;
 
function getSpinner( _type:String ) : MovieClip
{
	if( _type == "node" ) {
		nodeSpinner = new mcNodeSpinner();
		return nodeSpinner;
	}
	else {
		playlistSpinner = new mcPlaylistSpinner();
		return playlistSpinner;		
	}
}

function resizeSpinner( _type:String, _width:Number, _height:Number )
{
	var spinner:MovieClip = (_type == "node") ? nodeSpinner : playlistSpinner;
	if( spinner ) {
		spinner.loader_back.width = _width;
      spinner.loader_back.height = _height;		
		spinner.loader_mc.x = (_width / 2);
      spinner.loader_mc.y = (_height / 2);
   }
}
