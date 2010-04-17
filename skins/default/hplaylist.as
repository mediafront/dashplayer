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
		
var playlist:MovieClip = dash.playlist;
		
/**
 * Function to initialize your skin.  
 *
 * @param -  The Dash Media Player Base class.
 * @param -  The Dash Media Player Service class. (for calling services to Drupal and others).
 * @param -  The Dash Media Player Resizer class (for resizing objects)
 * @param -  The Dash Media Player Utils class. (common utilities used throughout the player).
 * @param -  The Dash Media Player Layout Manager. (to store all information from the layout XML file)
 * @param -  The Flash Variables Object (for handling all flashvars).
 * @param -  The Dash Media Player Interface class (for loading nodes, playlists, and handling media).
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
   
   setPlaylistSize();
   showPlaylistLinks();
   
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
 */
 
function getConfigInfo() : XML
{
   var settings:XML = 
            <params>
               <license></license>
               <gateway></gateway>
               <apiKey></apiKey>
               <baseURL></baseURL>
               <flashvars>
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
	   <width>500</width>
	   <height>120</height>
	   <autoHideX>1</autoHideX>
	   <autoHideY>1</autoHideY>	
	   <spacer>1</spacer>
	   <linkpadding>10</linkpadding>		
	   <resize>
		   <path>dash/playlist/backgroundMC</path>
		   <property>width</property>
	   </resize>								
	   <resize>
		   <path>dash/playlist/scrollRegion/listMask</path>
		   <property>width</property>
	   </resize>
	   <resize>
		   <path>dash/playlist/loader/loader_back</path>
		   <property>width</property>
	   </resize>
	   <resize>
		   <path>dash/playlist/loader/loader_mc</path>
		   <property>x</property>
		   <property>y</property>
	   </resize>
	   <resize>
		   <path>dash/playlist/navigation/next</path>
		   <property>x</property>
	   </resize>	
	   <resize>
		   <path>dash/playlist/links/listMask</path>
		   <property>width</property>
	   </resize>		
   </layout>;  
   
   return layout;
}

/**
 * Allows you to say which extensions are associated with what type of media.  This allows you to create custom media classes to handle
 * your media type specifically.
 *
 * @param - The exension of the media being played.
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
	      return "custom";		
	}
	
	return "custom";
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
 *             mediatype - The media type... this will always be "custom" here.
 *             mediaclass - This will always be "media" here...
 *             weight - The weight of this media.
 *
 * @return - Your custom media class           
 */

function getMedia( mediaFile:Object )
{
   // This is just an example...  not working yet, but if anyone is up for the challenge... ;)
   if( mediaFile.extension == "swf" ) 
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
 * Called when the teaser gets initialized.
 *
 * @param - The teaser object.
 */

function onTeaserInit( teaser:* )
{
	if( teaser.skin.backgroundMC )
	{
	   teaser.skin.backgroundMC["selected"].gotoAndStop( "_on" );
	   teaser.skin.backgroundMC["normal"].gotoAndStop( "_on" );			
   }
}

/**
 * Called when the teaser gets selected.
 *
 * @param - The teaser object.
 * @param - If the teaser has been selected or not
 */

function onTeaserSelect( teaser:*, select:Boolean ) 
{
	if( teaser.skin.backgroundMC )
   {
		teaser.skin.backgroundMC["selected"].visible = select;
      teaser.skin.backgroundMC["normal"].visible = !select;
	}
}

/**
 * Called when the mouse hovers over a teaser
 *
 * @param - The teaser object.
 */

function onTeaserOver( teaser:* )
{
	if( teaser.skin.backgroundMC )
   {		
	   teaser.skin.backgroundMC["selected"].gotoAndStop( "_over" );
	   teaser.skin.backgroundMC["normal"].gotoAndStop( "_over" );
	}	
}

/**
 * Called when the mouse moves out of hovering over a teaser.
 *
 * @param - The teaser object.
 */

function onTeaserOut( teaser:* )
{
	if( teaser.skin.backgroundMC )
   {		
	   teaser.skin.backgroundMC["selected"].gotoAndStop( "_on" );
	   teaser.skin.backgroundMC["normal"].gotoAndStop( "_on" );
	}	
}

/**
 * Called when the user presses the down button on the teaser.
 *
 * @param - The teaser object.
 */

function onTeaserDown( teaser:* )
{
	if( teaser.skin.backgroundMC )
   {		
	   teaser.skin.backgroundMC["selected"].gotoAndStop( "_down" );
	   teaser.skin.backgroundMC["normal"].gotoAndStop( "_down" );
	}
}

/**
 * Hook that allows you to return a MovieClip of a playlist link.
 *
 * @return - A new movie clip of your playlist link.
 */

function getPlaylistLink() : MovieClip
{
   return new mcPlaylistLink();
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
 * Called to set the width or height of the playlist.
 *
 * @param - The size (in pixels) that you would like to set the playlist.
 */

function setPlaylistSize()
{
	var playlistSize:uint = flashVars.playlistsize;
   if( playlistSize )
   {
      var _x:String = (flashVars.vertical) ? "x" : "y";
      var _width:String = (flashVars.vertical) ? "width" : "height";
      
      var offset:Number = playlistSize - playlist.scrollRegion.listMask[_width];
      dashResizer.setResizeProperty( playlist, "dash/playlist", _x, (playlist[_x] - offset) );
   	
	   if( playlist.backgroundMC ) {
		   playlist.backgroundMC[_width] += offset;
	   }
      
	   playlist.scrollRegion.listMask[_width] = playlistSize; 
	   playlist.loader["loader_back"][_width] = playlistSize;
      playlist.loader["loader_mc"][_x] = (playlistSize - playlist.loader["loader_mc"][_width]) / 2;
   	
	   if( flashVars.vertical ) {
		   if( playlist.links ) {
			   playlist.links.listMask.width += offset;
		   }
   		
		   if( playlist.autoPrev ) {
			   playlist.autoPrev.width += offset;
		   }
   		
		   if( playlist.autoNext ) {
			   playlist.autoNext.width += offset;
		   }
   		
		   if( playlist.navigation ) {
		      playlist.navigation.next.x += offset;
		   }
	   }
	}
}

/**
 * Called to show the dynamic links for the playlist.
 */

function showPlaylistLinks()
{
	if( (flashVars.linktext[0]) && (playlist.links.y == playlist.y) ) 
   {
	   var yOffset:Number = playlist.links.height;
   	
	   if( !flashVars.vertical && playlist.navigation ) {
		   playlist.navigation.height -= yOffset;
		   playlist.navigation.y += yOffset;
	   }
		
	   if( flashVars.vertical && playlist.autoPrev ) {
		   playlist.autoPrev.y += yOffset;					
	   }
		
		if( playlist.scrollRegion ) {
	   	dashResizer.setResizeProperty( playlist.scrollRegion.listMask, "dash/playlist/scrollRegion/listMask", "height", (playlist.scrollRegion.listMask.height - yOffset) );
	   	playlist.scrollRegion.y += yOffset;
		}
		
		if( playlist.loader ) {
			dashResizer.setResizeProperty( playlist.loader["loader_back"], "dash/playlist/loader/loader_back", "height", (playlist.loader["loader_back"].height - yOffset) );
			dashResizer.setResizeProperty( playlist.loader["loader_mc"], "dash/playlist/loader/loader_mc", "y", (playlist.loader["loader_mc"].y - yOffset) );			
			playlist.loader.y += yOffset;
		}
		
		if( playlist.backgroundMC ) {
			dashResizer.setResizeProperty( playlist.backgroundMC, "dash/playlist/backgroundMC", "height", (playlist.backgroundMC.height - yOffset) );
			playlist.backgroundMC.y += yOffset;
		}
   }
}
