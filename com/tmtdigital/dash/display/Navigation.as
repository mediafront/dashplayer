package com.tmtdigital.dash.display
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.Image;
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.net.Gateway;
   import com.tmtdigital.dash.config.Params;

   import flash.display.*;
   import flash.events.*;
   import flash.net.*;

   public class Navigation extends Skinable
   {
      public function Navigation( _skin:MovieClip )
      {
         super( _skin );
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin(_skin);

         logo = new Image( skin.logo );
         bar = skin.bar;
         grad = skin.grad;
         next = skin.next;
         prev = skin.prev;
      }

      public function loadNavigation()
      {
         if (next) {
            next.buttonMode = true;
            next.mouseChildren = false;
            next.addEventListener( MouseEvent.MOUSE_UP, onMouseEvent );
         }

         if (prev) {
            prev.buttonMode = true;
            prev.mouseChildren = false;
            prev.addEventListener( MouseEvent.MOUSE_UP, onMouseEvent );
         }
      }

      private function onMouseEvent( e:MouseEvent )
      {
         switch ( e.target.name ) {
            case "prev" :
               Gateway.prevPage( false, Params.flashVars.disableplaylist );
               break;

            case "next" :
               Gateway.nextPage( false, Params.flashVars.disableplaylist );
               break;
         }
      }

      public function loadLogo()
      {
         if( logo && logo.skin && Params.flashVars.playlistlogo ) {
            if (Params.flashVars.link) {
               logo.skin.buttonMode = true;
               logo.skin.mouseChildren = false;
               logo.skin.addEventListener( MouseEvent.MOUSE_UP, Utils.gotoUserWebsite );
            }
            
            logo.loadImage( Params.flashVars.playlistlogo );
         }
      }

      public var logo:Image;
      public var bar:Sprite;
      public var grad:Sprite;
      public var next:MovieClip;
      public var prev:MovieClip;
   }
}