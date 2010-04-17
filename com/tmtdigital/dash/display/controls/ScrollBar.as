/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The ScrollBar class is used to define a scroll bar to be 
 *               used with the scroll region.
 *
 **/

package com.tmtdigital.dash.display.controls
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.events.DashEvent;
   import com.tmtdigital.dash.utils.Resizer; 
   import com.tmtdigital.dash.config.Params;   

   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import fl.transitions.*;
   import fl.transitions.easing.*;

   public class ScrollBar extends Skinable
   {
      public function ScrollBar( _skin:MovieClip, _setListPos:Function )
      {
         setListPosition = _setListPos;
         _handlePos = 0;
         ratio = -1;
         isPrev = false;
         isNext = false;

         _y = Params.flashVars.vertical ? "y":"x";
         _height = Params.flashVars.vertical ? "height":"width";
         _localY = Params.flashVars.vertical ? "localY":"localX";
         super( _skin );
      }

      /**
       * Sets the skin of this object.
       *
       * @param - The skin object to set.
       */
      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );

         track = skin.track;

         if (track["handle"]) {
            handleTween = new Tween(track["handle"],_y,Strong.easeOut,track["handle"][_y],track["handle"][_y],Resizer.tweenTime);
            handleTween.stop();

            track["handle"].buttonMode = true;
            track["handle"].mouseChildren = false;
            track["handle"].addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
            track["handle"].addEventListener(MouseEvent.MOUSE_UP, onDragStop);
            track["handle"].addEventListener(MouseEvent.MOUSE_OUT, onDragStop);
            track["handle"][_y] = 0;
         }

         if (track["button"]) {
            track["button"].buttonMode = true;
            track["button"].mouseChildren = false;
            track["button"].addEventListener(MouseEvent.MOUSE_UP, onScrollButton );
         }
         
         prev = skin.prev;
         if( prev ) {
            prev.buttonMode = true;
            prev.mouseChildren = false;
            prev.addEventListener(MouseEvent.MOUSE_UP, onButtonPressed);
            prev.addEventListener(MouseEvent.MOUSE_DOWN, onButtonPressed);
         }

         next = skin.next;
         if( next ) {
            next.buttonMode = true;
            next.mouseChildren = false;
            next.addEventListener(MouseEvent.MOUSE_UP, onButtonPressed);
            next.addEventListener(MouseEvent.MOUSE_DOWN, onButtonPressed);
         }
      }

      private function onDragStart(event:MouseEvent)
      {
         event.target.startDrag( false, trackRect );
         track.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
      }

      private function onDragStop(event:MouseEvent)
      {
         track.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);

         isPrev = false;
         isNext = false;
         event.target.stopDrag();

         dispatchEvent( new DashEvent( DashEvent.STOP ) );
      }

      private function onDrag(event:MouseEvent)
      {
         // Store the handle position
         _handlePos = track["handle"][_y];

         // Now set the list position.
         setListPosition( (_handlePos * ratio), false );
      }

      private function onScrollButton( event:MouseEvent )
      {
         // Set the handle position.
         setHandlePos(event[_localY], true );

         // Now set the list position.
         setListPosition( (_handlePos * ratio), true );
      }

      private function onButtonPressed( event:MouseEvent )
      {
         switch ( event.type ) {
            case MouseEvent.MOUSE_UP :
               if ((event.target.name == "prev") && isPrev) {
                  dispatchEvent( new DashEvent( DashEvent.PREV ) );
               } else if ((event.target.name == "next") && isNext) {
                  dispatchEvent( new DashEvent( DashEvent.NEXT ) );
               }
               break;

            case MouseEvent.MOUSE_DOWN :
               isPrev = (event.target.name == "prev") ? true : false;
               isNext = (event.target.name == "next") ? true : false;
               break;
         }
      }

      public function setupScrollBar( listSize:Number, listMaskSize:Number )
      {
         _handlePos = 0;

         if (track) {
            var _trackSize:uint = track[_height];
            var _handleSize:uint = Params.flashVars.autoscroll ? (( listMaskSize / listSize ) * _trackSize) : track["handle"][_height];
            trackLength = _trackSize - _handleSize;
            trackRect = new Rectangle();
            trackRect[_height] = trackLength;
            track["handle"][_height] = _handleSize;
            ratio = -((listSize - listMaskSize) / trackLength);
         } else {
            trackLength = listSize - listMaskSize;
         }
      }

      public function getListPos():Number
      {
         return (_handlePos * ratio);
      }

      public function setListPos( listPos:Number, tween:Boolean = false )
      {
         setHandlePos( (listPos / ratio), tween );
      }

      public function get handlePos():Number
      {
         return _handlePos;
      }

      /**
       * Sets the handle position.
       *
       * @param - The list poisiton in pixels.
       * @param - Boolean to indicate if we should tween this movement.
       */
      public function setHandlePos( hPos:Number, tween:Boolean = false )
      {
         _handlePos = (hPos < 0) ? 0 : hPos;
         _handlePos = (_handlePos > trackLength) ? trackLength : _handlePos;

         if (track) {
            if (tween) {
               handleTween.stop();
               handleTween.begin = track["handle"][_y];
               handleTween.finish = _handlePos;
               handleTween.start();
            } else {
               track["handle"][_y] = _handlePos;
            }
         }
      }

      public var track:Sprite;
      public var prev:Sprite;
      public var next:Sprite;

      private var trackLength:Number;
      private var trackRect:Rectangle;
      private var ratio:Number;

      private var setListPosition:Function;

      private var _handlePos:Number;
      private var handleTween:Tween;
      private var isPrev:Boolean;
      private var isNext:Boolean;

      private var _y:String;
      private var _height:String;
      private var _localY:String;
   }
}