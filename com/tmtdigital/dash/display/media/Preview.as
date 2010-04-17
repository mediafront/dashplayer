/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The Preview class is used to manage the preview screen
 * within the media region of the player. 
 *
 **/

package com.tmtdigital.dash.display.media
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.media.PreviewMask;   
   import com.tmtdigital.dash.utils.Utils;

   import flash.display.*;
   import fl.transitions.*;
   import fl.transitions.easing.*;
   import flash.events.*;
   import flash.net.*;
   import flash.geom.*;

   class Preview extends Skinable
   {
      private static const playPreviewGrow:uint = 10;
      private static const playPreviewTween:uint = 7;

      public function Preview( _skin:MovieClip, _playFile:Function, _resizeMedia:Function )
      {
         playFile = _playFile;
         resizeMedia = _resizeMedia;
         super( _skin );
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );

         previewMask = new PreviewMask( skin.previewMask );

         button = skin.button;

         if (button) {
            buttonX = button.x;
            buttonY = button.y;
            buttonWidth = button.width;
            buttonHeight = button.height;

            xTween = new Tween(button, "x", Strong.easeIn, button.x, button.x - (playPreviewGrow/2), playPreviewTween);
            xTween.stop();

            yTween = new Tween(button, "y", Strong.easeIn, button.y, button.y - (playPreviewGrow/2), playPreviewTween);
            yTween.stop();

            widthTween = new Tween(button,"width",Strong.easeIn,button.width,button.width + playPreviewGrow,playPreviewTween);
            widthTween.stop();

            heightTween = new Tween(button,"height",Strong.easeIn,button.height,button.height + playPreviewGrow,playPreviewTween);
            heightTween.stop();

            button.buttonMode = true;
            button.mouseChildren = false;
            button.addEventListener( MouseEvent.MOUSE_UP, onPlay );
            button.addEventListener( MouseEvent.MOUSE_OVER, onPlayOver );
            button.addEventListener( MouseEvent.MOUSE_OUT, onPlayOut );
         }
      }

      public function unloadPreview()
      {
         if( previewMask ) {
            previewMask.unloadPreview();
         }
      }

      public function postResize( mediaRect:Rectangle )
      {
         if( previewMask ) {
            previewMask.postResize( mediaRect );
         }

         if( button ) {
            button.x = (mediaRect.width - button.width) / 2;
            button.y = (mediaRect.height - button.height) / 2;
            buttonX = button.x;
            buttonY = button.y;
         }
      }

      public function setPlayState( _play:Boolean, _showImage:Boolean )
      {
         if( previewMask ) {
            previewMask.setPlayState( _play, _showImage );
         }

         if( button ) {
            button.visible = ! _play;
         }
      }

      public function getPreview():String
      {
         if( previewMask ) {
            return previewMask.getPreview();
         }
         
         return "";
      }

      public function loadPreview( _file:String )
      {
         if( previewMask ) {
            previewMask.loadPreview( _file, resizeMedia );
         }
      }

      private function onPlay( event:MouseEvent ):void
      {
         playFile();
      }

      private function onPlayOver( event:MouseEvent ):void
      {
         xTween.begin = buttonX;
         xTween.finish = buttonX - (playPreviewGrow / 2);
         yTween.begin = buttonY;
         yTween.finish = buttonY - (playPreviewGrow / 2);
         widthTween.begin = buttonWidth;
         widthTween.finish = buttonWidth + playPreviewGrow;
         heightTween.begin = buttonHeight;
         heightTween.finish = buttonHeight + playPreviewGrow;

         xTween.start();
         yTween.start();
         widthTween.start();
         heightTween.start();
      }

      private function onPlayOut( event:MouseEvent ):void
      {
         xTween.begin = button.x;
         xTween.finish = buttonX;
         yTween.begin = button.y;
         yTween.finish = buttonY;
         widthTween.begin = button.width;
         widthTween.finish = buttonWidth;
         heightTween.begin = button.height;
         heightTween.finish = buttonHeight;

         xTween.start();
         yTween.start();
         widthTween.start();
         heightTween.start();
      }

      public var button:Sprite;
      public var previewMask:PreviewMask;

      private var xTween:Tween;
      private var yTween:Tween;
      private var widthTween:Tween;
      private var heightTween:Tween;
      private var buttonX:Number;
      private var buttonY:Number;
      private var buttonWidth:Number;
      private var buttonHeight:Number;
      private var resizeMedia:Function;
      private var playFile:Function;
   }
}