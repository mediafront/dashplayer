import fl.transitions.*;
import fl.transitions.easing.*;

var dashBase:*;
var dashService:*; 
var dashResizer:*;
var dashUtils:*;
var dashLayout:*;
var flashVars:*;
var dashInterface:*;

var menu:MovieClip = null;
var menuTween:Tween;
var menuVisible:Boolean = false;

		
/**
 * Function to initialize the menu.  
 *
 * @param - The type of menu this is... "node" or "teaser"
 * @param - The Dash Media Player Base class.
 * @param - The Dash Media Player Service class. (for calling services to Drupal and others).
 * @param - The Dash Media Player Resizer class (for resizing objects)
 * @param - The Dash Media Player Utils class. (common utilities used throughout the player).
 * @param - The Dash Media Player Layout Manager. (to store all information from the layout XML file)
 * @param - The Flash Variables Object (for handling all flashvars).
 * @param - The Dash Media Player Interface class (for loading nodes, playlists, and handling media).
 *
 * @return - The Menu MovieClip
 */
 
function getMenu( _type:String, _dashBase:*, _dashService:*, _dashResizer:*, _dashUtils:*, _dashLayout:*, _flashVars:*, _dashInterface:* ) : MovieClip
{
   dashBase = _dashBase;
   dashService = _dashService;
   dashResizer = _dashResizer;
   dashUtils = _dashUtils;
   dashLayout = _dashLayout;
   flashVars = _flashVars;
   dashInterface = _dashInterface;
	menu = new mcMenu();
	menu.visible = false;
   return menu;
}

/**
 * Returns the layout information of this skin.
 *
 * @return - Your XML layout information.
 */

function getLayoutInfo() : XML
{
   var layout:XML = 
   <layout>						
   	<resize>
			<prefix>dash/node/fields/</prefix>		
   		<path>menu/backgroundMC</path>
   		<property>width</property>
   		<property>height</property>
   	</resize>
   	<resize>
			<prefix>dash/node/fields/</prefix>		
   		<path>menu/embed</path>
   		<property>y</property>
   	</resize>
   	<resize>
			<prefix>dash/node/fields/</prefix>		
   		<path>menu/embed/embedcode</path>
   		<property>width</property>
   	</resize>	 
   </layout>;
   return layout;
}

/**
 * Called when the toggle menu mode button gets pressed.
 *
 * @param - True:  Menu is on,  False:  Menu is off.
 * @param - If this should be a tween resize event or not.
 */
function toggleMenuMode( on:Boolean, tween:Boolean )
{
	menuVisible = on;
	if( menuVisible ) {
	   menu.visible = menuVisible;
	}
	
	var newX:Number = on ? 0 : -(menu.width + 5);
	if( menuTween ) {
		menuTween.stop();
	}		

	menuTween = new Tween( menu, "x", Strong.easeIn, menu.x, newX, 15 );
	menuTween.removeEventListener( TweenEvent.MOTION_FINISH, onMenuFinish );
	menuTween.addEventListener( TweenEvent.MOTION_FINISH, onMenuFinish );	
}

/**
 * Called when the menu has finished moving off the screen.  Here we will just hide the menu when 
 * it is not in use.
 *
 * @param - A standard tween event.
 */
function onMenuFinish(e:TweenEvent) 
{
	menu.visible = menuVisible;
}

/**
 * Allow the skin to provide their own embed code.
 *
 *	@param - The URL of the player SWF file.
 * @param - The path to the media file to embed.
 * @param - The image provided with the media file to embed.
 * @param - An array of extra flashVars.
 */
function getEmbedCode( loaderURL:String, mediaFile:String, imageFile:String, embedVars:Array )
{
   var paramVars:String = ((embedVars.length > 0) ? embedVars.join("&") : "");
   var flashVarString:String = "";

   if (mediaFile) {
      flashVarString = "file=" + mediaFile;
		flashVarString += "&autostart=false";

		if (imageFile) {
			flashVarString+="&image="+imageFile;
		}

		flashVarString += paramVars ? ("&" + paramVars) : "";
	}

	var embedText:String="<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" ";
	embedText+="width=\""+flashVars.embedwidth+"\"";
	embedText+="height=\""+flashVars.embedheight+"\"";
	embedText+="codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab\">\n";
	embedText+="<param name=\"movie\" value=\""+loaderURL+"\" />\n";
	embedText+="<param name=\"wmode\" value=\"transparent\"/>\n";
	embedText+="<param name=\"allowfullscreen\" value=\"true\"/>\n";
	embedText+="<param name=\"FlashVars\" value=\""+flashVarString+"\" />\n";
	embedText+="<param name=\"quality\" value=\"high\"/>\n";
	embedText+="<embed allowScriptAccess=\"always\" src=\""+loaderURL+"\"";
	embedText+="width=\""+flashVars.embedwidth+"\"";
	embedText+="height=\""+flashVars.embedheight+"\"";
	embedText+="border=\"0\" type=\"application/x-shockwave-flash\" ";
	embedText+="pluginspage=\"http://www.macromedia.com/go/getflashplayer\" wmode=\"transparent\" ";
	embedText+="allowfullscreen=\"true\" quality=\"high\" ";
	embedText+="flashvars=\""+flashVarString+"\" />\n</object>\n";
	return embedText;
}
