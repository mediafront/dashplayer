/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Functionality for the menu section of the Dash Player.
 *
 **/

package com.tmtdigital.dash.display
{
	import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.net.Service;
	import com.tmtdigital.dash.utils.Resizer;
	import com.tmtdigital.dash.utils.Utils;
	import com.tmtdigital.dash.utils.LayoutManager;
	import com.tmtdigital.dash.net.Gateway;
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.config.Params;   
   
   import flash.text.*;
   import flash.display.*;
   import flash.events.*;

   public class Menu extends Skinable
   {
      public function Menu( _skin:MovieClip, _type:String )
      {
			var _skinPath:String = "";
			type = _type;
			
         if( Params.flashVars.menu && !Params.flashVars.disablemenu ) {
            _skinPath = Params.getRootPath();
            _skinPath += "/plugins/menus/" + Params.flashVars.menu + "/menu.swf";
         }
			
         super( _skin, _skinPath );
      }

      public override function getSkin( newSkin:MovieClip ) : MovieClip
      {
         if( rootSkin && (rootSkin.getMenu is Function) ) {
            return rootSkin.getMenu( type, DashPlayer, Service, Resizer, Utils, LayoutManager, Params.flashVars, Gateway );
         }
         
         return newSkin;         
      }

      public override function setSkin(_skin:MovieClip)
      {
         super.setSkin(_skin);
         embed = skin.embed;
         if( embed ) {
         	embed.visible = ! Params.flashVars.disableembed;
         }
      }

      public function loadMenu()
      {
         if (embed) {
            var embedText:String = "";
            var mediaFile:String = "";
            var imageFile:String = "";

            if (DashPlayer.media) {
               mediaFile = DashPlayer.media.getEmbedMediaFile();

               if (DashPlayer.media.preview) {
                  imageFile = DashPlayer.media.preview.getPreview();
               }
            }

            if( rootSkin && (rootSkin.getEmbedCode is Function) ) {
               embedText = rootSkin.getEmbedCode(Params.loaderURL,mediaFile,imageFile,Params.embedVars);
            } 

            embed["embedcode"].text = embedText;
            embed["embedcode"].addEventListener(MouseEvent.CLICK, clickHandler);
            embed["embedcode"].addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
         }
      }

      public function toggleMenuMode(on:Boolean, tween:Boolean = true)
      {
         if ( rootSkin && (rootSkin.toggleMenuMode is Function) && (menuMode != on) ) {
            menuMode = on;
            rootSkin.toggleMenuMode( on, tween );
         }
      }

      private function onShuffle( on:Boolean )
      {
         Params.flashVars.shuffle=on;
      }

      private function clickHandler(event:MouseEvent):void
      {
         embed["embedcode"].setSelection(0, embed["embedcode"].length);
      }

      private function mouseUpHandler(event:MouseEvent):void
      {
         embed["embedcode"].setSelection(0, embed["embedcode"].length);
      }

      public var embed:MovieClip;
      public var menuMode:Boolean=false;		
      private var type:String;		
   }
}