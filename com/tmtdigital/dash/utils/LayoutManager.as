/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The LayoutManager class is used to keep track of all layout
 * properties of the player.  It manages the skin, theme colors, disabled-enabled components, layout states, etc.
 *
 **/

package com.tmtdigital.dash.utils
{
   import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.utils.Resizer;
   import com.tmtdigital.dash.config.Params;       

   import flash.net.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.text.*;
   import fl.transitions.*;
   import fl.transitions.easing.*;

   public class LayoutManager
   {
      public static function loadLayout( _layout:XML )
      {
         autoHideX = _layout.autoHideX;
         autoHideY = _layout.autoHideY;
         DashPlayer.oldScreenWidth = _layout.width;
         DashPlayer.oldScreenHeight = _layout.height;
         spacer = _layout.spacer;
         linkpadding = _layout.linkpadding;
         Resizer.loadLayout(_layout);

         if (_layout.hasOwnProperty("flashvars")) {
            Params.loadFlashVars( _layout.flashvars );
         }
      }

      public static function loadTheme( _onLoaded:Function )
      {
         onLoaded = _onLoaded;

         if (Params.flashVars.theme != "default") {
            var configURL:String = Params.getRootPath();
            var xmlURL:String = configURL + "/skins/" + DashPlayer.skinName + "/themes/" + Params.flashVars.theme + "/theme.xml";
            Utils.loadXML( xmlURL, onThemeLoad, setupLayout );
         } else if ( onLoaded is Function ) {
            onLoaded();
         }
      }

      private static function onThemeLoad(e:Event)
      {
         theme = new XML(e.target.data);
         setupLayout();
      }

      private static function setupLayout(event:Object = null)
      {
         if ( DashPlayer.dash.skin ) {
            setColors( DashPlayer.skin.dash, "", "teaser" );
         }

         if (onLoaded is Function) {
            onLoaded();
         }
      }

      private static function setColors( refObject:*, _path:String = "", _except:String = "" )
      {
         // Only continue if they have a theme, and colors with fills defined.
         if (theme && theme.colors && theme.fill) {
            // Iterate through each of the fill elements.
            for each (var fill in theme.fill) {
               // Iterate through each of the paths within the fill elements.
               for each (var path in fill.path) {
                  // Do we need to filter this path?
                  if (Utils.filterPath(path,_path,_except)) {
                     // Actually grab the object from the path provided.
                     var obj:* = Utils.getObjectFromPath(refObject,path);
                     if (obj) {
                        setFill( obj, fill );
                     }
                  }
               }
            }
         }
      }

      private static function setFill( mc:*, fill:XML )
      {
         var mcColor:ColorTransform = mc.transform.colorTransform;
         var colorObj:Object = getColor( fill.color );
         if( colorObj.valid ) {
            mcColor.color = colorObj.color;
         }
         mc.transform.colorTransform = mcColor;
      }

      private static function getColor( _color:String ) : Object
      {
         var themeColor:* = theme.colors[_color];
         var _valid:Boolean = false;
         
         if( themeColor.indexOf("color") == 0 ) {
            if( Params.flashVars.colors.hasOwnProperty( themeColor ) ) {
               themeColor = Params.flashVars.colors[themeColor];
               _valid = true;
            }
         }
         else {
            themeColor = (themeColor.indexOf("color") == 0) ? Params.flashVars.colors[themeColor] : themeColor;
            _valid = true;
         }
         
         return {color:uint(themeColor), valid:_valid};
      }

      public static function themeTeaser( teaserMC:* )
      {
         setColors( teaserMC, "teaser" );
      }

      public static var theme:XML;
      public static var spacer:int;
      public static var linkpadding:uint;
      public static var autoHideX:int;
      public static var autoHideY:int;
      public static var onLoaded:Function;
   }
}