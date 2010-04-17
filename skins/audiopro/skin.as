/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The skin.as file can be used by your skin to hook into the Dash Media Player and 
 * completely customize how the player behaves.  It allows you to use many of the facilities already
 * placed in the Dash Media Player so that you can truely have your very own player using the power
 * of the Dash Media Player
 **/

// include "SWFMedia.as"

import fl.transitions.*;
import fl.transitions.easing.*;
import flash.geom.Rectangle;

var dashBase:*;
var dashService:*; 
var dashResizer:*;
var dashUtils:*;
var dashLayout:*;
var flashVars:*;
var dashInterface:*;

var mediaRect:Rectangle;

var menuTween:Tween;
var controlTween:Tween;
		
var node:MovieClip = dash.node;
var media:MovieClip = dash.node.fields.media;
var menu:MovieClip = dash.node.fields.menu;
var controlBar:MovieClip = dash.node.fields.media.controlBar;
var menuButton:MovieClip = dash.node.fields.media.controlBar.menuButton;
var toggleFullScreen:MovieClip = dash.node.fields.media.controlBar.toggleFullScreen;
var playlist:MovieClip = dash.playlist;

var menuVisible:Boolean = false;

function onSpawn( e:MouseEvent )
{
	if( ExternalInterface.available ) {
		ExternalInterface.call("spawn", "test");
	}
}
		
/**
 * Function to initialize your skin.  
 *
 * @param - The Dash Media Player Base class.
 * @param - The Dash Media Player Service class. (for calling services to Drupal and others).
 * @param - The Dash Media Player Resizer class (for resizing objects)
 * @param - The Dash Media Player Utils class. (common utilities used throughout the player).
 * @param - The Dash Media Player Layout Manager. (to store all information from the layout XML file)
 * @param - The Flash Variables Object (for handling all flashvars).
 * @param - The Dash Media Player Interface class (for loading nodes, playlists, and handling media).
 *
 * @return - True to indicate to the media player to start loading content.
 *           False to let the skin take over from here and do what it needs to do.
 */

function initialize( _dashBase:*, _dashService:*, _dashResizer:*, _dashUtils:*, _dashLayout:*, _flashVars:*, _dashInterface:* ) : Boolean
{
   dashBase = _dashBase;
   dashService = _dashService;
   dashResizer = _dashResizer;
   dashUtils = _dashUtils;
   dashLayout = _dashLayout;
   flashVars = _flashVars;
   dashInterface = _dashInterface;

   return true;
}

/**
 * Allows you to provide all your information within your skin file so that you do not have to expose the configuration XML
 * file to outside parties.  If you wish to use this, simply fill in the information below, and then provide the variable "config=internal"
 * to the dash media player.  For example, using the Dash Media Player API, I would use the following to read this information instead
 * of reading the configuration XML file...
 *
 *    $params['width']  = 652;
 *    $params['height'] = 432;
 *    $params['config'] = 'internal';
 *    $params['playlist'] = 'videos';
 *    priint dashplayer_get_player($params);
 *
 * @return - Your XML configuration, as it would be in the dashconfig.xml file.
 */
 
function getConfigInfo() : XML
{
   var settings:XML = 
            <params>
               <flashvars>
						<autoscroll>false</autoscroll>
						<vertical>false</vertical>   
						<volumevertical>true</volumevertical>
						<teaserplay>true</teaserplay>
						<embedwidth>520</embedwidth>
						<embedheight>111</embedheight>
						<pagelimit>1000</pagelimit>
               </flashvars>
            </params>;
   
   return settings;
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
   	<width>520</width>
   	<height>111</height>
   	<autoHideX>1</autoHideX>
   	<autoHideY>1</autoHideY>	
   	<spacer>1</spacer>
   	<linkpadding>10</linkpadding>
   </layout>;
      
   return layout;
}

/**
 * Allows you to say which extensions are associated with what type of media.  This allows you to create custom media classes to handle
 * your media type specifically.
 *
 * @param - The exension of the media being played.
 *
 * @return - The media type associated with this extension.
 */

function getMediaType( extension:String ) : String
{	
	switch( extension )
	{
		case "flv":
		case "rtmp":
      case "mp4":
      case "m4v": 
      case "mov":
      case "3g2":
			return "video";
			
		case "mp3":				
      case "m4a":
      case "aac": 
      case "ogg":
      case "wav":
      case "aif":
      case "wma":				
			return "audio";
			
		case "jpg":
      case "gif": 
      case "png":
			return "image";
			
	   default:
	      return "";		
	}
	
	return "";
}

/**
 * When your media type is "custom", the dash media player will then call this routine to grab a media handling
 * class.  This can be anything class to handle any type of media like SWF files, ect.  
 * For an example stub class to be used to build your own, refer to the SWFMedia.as file.
 *
 * @param - The media file object to play.
 *             path - The full path of the media file.
 *             filename - The filename of the media file.
 *             extension - The file extension...
 *             mediatype - The media type... 
 *             mediaclass - This will always be "media" here...
 *             weight - The weight of this media.
 *
 * @return - Your custom media class           
 */

function getMedia( mediaFile:Object )
{
   // This is just an example...  not working yet, but if anyone is up for the challenge... ;)
   if( mediaFile.mediatype == "custom" ) 
   {
      /**
       * Example on how this is done... the SWFMedia is only a stub file right now, but maybe someone can
       * get it working.  ;)
       *
       *    var mediaHandler:SWFMedia = new SWFMedia();
       *    media.mediaRegion.addChild( mediaHandler );
       *    return mediaHandler;
       */
      
      return null;
   }
   else 
   {
      return null;
   }
}

/**
 * Called when the media starts playing...
 */

function onMediaPlaying()
{
}

/**
 * Called when the media finishes playing...
 */

function onMediaComplete()
{
}

function getControlBar( type:String ) : MovieClip
{
	if( type == "teaser" ) {
		return new mcTeaserControl();
	}
	else {
		return new mcControlBar();
	}
}

/**
 * Hook that allows you to return a MovieClip of your teaser.
 *
 * @return - A new movie clip of your teaser.
 */

function getTeaser() : MovieClip
{
   return new mcTeaser();
}

/**
 * Called when the toggle menu mode button gets pressed.
 *
 * @param - True:  Menu is on,  False:  Menu is off.
 * @param - If this should be a tween resize event or not.
 */

function toggleMenuMode( on:Boolean, tween:Boolean )
{
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
}

/**
 * Called when the teaser gets initialized.
 *
 * @param - The teaser object.
 */

function onTeaserInit( teaser:* )
{
}

/**
 * Called when the teaser gets selected.
 *
 * @param - The teaser object.
 * @param - If the teaser has been selected or not
 */

function onTeaserSelect( teaser:*, select:Boolean ) 
{
}

/**
 * Called when the mouse hovers over a teaser
 *
 * @param - The teaser object.
 */

function onTeaserOver( teaser:* )
{
}

/**
 * Called when the mouse moves out of hovering over a teaser.
 *
 * @param - The teaser object.
 */

function onTeaserOut( teaser:* )
{
}

/**
 * Called when the user presses the down button on the teaser.
 *
 * @param - The teaser object.
 */

function onTeaserDown( teaser:* )
{
}

/**
 * Hook that gets called when a node loads in the system
 *
 * @param - A standard Drupal node object.
 */

function onNodeLoad( node:Object )
{	
}

/**
 * Hook that gets called when a node loads in the system
 *
 * @param - A standard Drupal view object.
 */

function onPlaylistLoad( playlist:Object )
{
}

/**
 * Hook when the mouse is moved when the player is in full screen mode.
 *
 * @param - The x-position of the mouse.
 * @param - The y-position of the mouse.
 */

function onFullScreenMove( mouseX:Number, mouseY:Number )
{
}

/**
 * Hook when the inactive timout occurs when in full screen mode.  Typically you should
 * hide everything at this point.
 */

function onFullScreenHide()
{
}

/**
 * Hook when the player goes in and out of full screen.
 *
 * @param - True:  Fullscreen,  False:  Normal
 */

function onFullScreen( full:Boolean ) 
{
	if( full ) {
   	dashBase.setSkin( "meterrecordsfull" );
	}
}

/**
 * Ability to change how the resizer tweens its resize transitions.
 */

function getTweenFunction() : Function
{
   return Strong.easeIn;
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
	flashVarString = "playlist=" + flashVars.playlist;
	flashVarString += "&autostart=false";
	flashVarString += paramVars ? ("&" + paramVars) : "";			
	
	var embedText:String = "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" ";
	embedText += "width=\""  + flashVars.embedwidth  + "\" ";
	embedText += "height=\"" + flashVars.embedheight + "\" ";
	embedText += "codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab\">\n";
	embedText += "<param name=\"movie\" value=\"" + loaderURL + "\" />\n";
	embedText += "<param name=\"wmode\" value=\"transparent\" />\n";
	embedText += "<param name=\"allowfullscreen\" value=\"true\" />\n";
	embedText += "<param name=\"FlashVars\" value=\"" + flashVarString + "\" />\n";
	embedText += "<param name=\"quality\" value=\"high\" />\n";
	embedText += "<embed allowScriptAccess=\"always\" src=\"" + loaderURL + "\" ";
	embedText += "width=\""  + flashVars.embedwidth  + "\" ";
	embedText += "height=\"" + flashVars.embedheight + "\" ";
	embedText += "border=\"0\" type=\"application/x-shockwave-flash\" ";
	embedText += "pluginspage=\"http://www.macromedia.com/go/getflashplayer\" wmode=\"transparent\" ";
	embedText += "allowfullscreen=\"true\" quality=\"high\" ";
	embedText += "flashvars=\"" + flashVarString + "\" />\n</object>\n";	
	return embedText;
}

/**
 * Hook to allow your to format the time indication however you would like it to be formated.
 *
 *	@param - The time in seconds.
 * 
 * @return - An object that represents both the units and the time as Strings.
 */

function formatTime(mediaTime:Number) : Object
{
	mediaTime *= 10;
	var timeUnits:String = "s";
	if( mediaTime > 600 )
   {
      mediaTime /= 60;
      timeUnits = "m";
   }
		   
   if( mediaTime > 600 )
   {
      mediaTime /= 60;
      timeUnits = "h";
   }
		   
	mediaTime = Math.ceil( mediaTime );
	mediaTime /= 10;
	mediaTime = ( timeUnits == "s" ) ? Math.ceil( mediaTime ) : mediaTime;
	return {time:mediaTime, units:timeUnits};
}