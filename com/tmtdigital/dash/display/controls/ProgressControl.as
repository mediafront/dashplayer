/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The ProgressControl is a custom control written to provide base
 * functionality for both the SeekBar and the VolumeBar components.
 *
 **/

package com.tmtdigital.dash.display.controls
{
   import com.tmtdigital.dash.display.Skinable;
   
   import flash.events.*;
   import flash.geom.*;
   import flash.display.*;
   import flash.utils.*;

   public class ProgressControl extends Skinable
   {
      public static const dragInterval:uint = 250;

      public function ProgressControl( _skin:MovieClip, _setControlValue:Function, _setControlDisp:Function, _vertical:Boolean )
      {
         vertical = _vertical;
         setControlValue = _setControlValue;
			setControlDisp = _setControlDisp;
         super( _skin );
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );

         handle = skin.handle;
         button = skin.button;
         fullness = skin.fullness;
         progress = skin.progress;
         
         _x = (!vertical) ? "x" : "y";
         _width = (!vertical) ? "width" : "height";
         _localX = (!vertical) ? "localX" : "localY";

         enableButton();
         enableHandle();
         dragTimer = new Timer(dragInterval);
         dragTimer.stop();
         dragTimer.addEventListener( TimerEvent.TIMER, onDragTimer );
         postResize();
      }

      /**
       * Called after a resize operation.  We will need to update the control properties.
       **/
      public function postResize():void
      {
         if (_width) {
            handleSize = 0;
            
            if (handle && handle["handleBar"]) {
               handleSize = handle ? handle["handleBar"][_width]:0;
            } else if ( handle ) {
               handleSize = handle ? handle[_width]:0;
            }

            if (button) {
               controlSize = button[_width] - handleSize;
            }

            if (handle) {
               dragRect = new Rectangle();
               dragRect[_width] = controlSize;
            }

            updateValue();
            setProgress();
         }
      }

      /**
       * Enables the bar button allowing the user press anywhere on the bar and the value get set.
       *
       * @param   Boolean -  True : Enable   False : Disable
       **/
      public function enableButton( _enable:Boolean = true )
      {
         button.buttonMode = _enable;
         button.mouseChildren = ! _enable;

         if (_enable) {
            button.removeEventListener( MouseEvent.MOUSE_UP, onSetValue );
            button.addEventListener( MouseEvent.MOUSE_UP, onSetValue );
         } else {
            button.removeEventListener( MouseEvent.MOUSE_UP, onSetValue );
         }
      }

      /**
       * Enables the drag handle allowing the user to set the value by dragging the handle.
       *
       * @param   Boolean -  True : Enable   False : Disable
       **/
      public function enableHandle( _enable:Boolean = true )
      {
         if (handle) {
            handle.buttonMode = _enable;
            handle.mouseChildren = ! _enable;

            if (_enable) {
               handle.addEventListener( MouseEvent.MOUSE_DOWN, onHandleDown );
               handle.addEventListener( MouseEvent.MOUSE_UP, onHandleUp );
            } else {
               handle.removeEventListener( MouseEvent.MOUSE_DOWN, onHandleDown );
               handle.removeEventListener( MouseEvent.MOUSE_UP, onHandleUp );
            }
         }
      }

      /**
       * Updates the value of this progress control
       *
       * @param   value (Number) -  A number from 0 to 1 indicating the percentage this value is set at.
       **/
      public function updateValue( _value:Number = -1 )
      {
         if( _value <= 1 ) {
            if (_value >= 0) {
               currentValue = _value;
            }
   
            var position:Number = Math.ceil(currentValue * controlSize);
   
            if ( fullness ) {
               fullness[_width] = position;
            }	
   
            if (handle) {
               handle[_x] = position;
            }
         }
      }

      /**
       * Sets the value based on user interaction.
       *
       * @param   value (Number) -  A number from 0 to 1 indicating the percentage this value is set at.
       **/
      public function setValue( _value:Number = -1 ):void
      {
         _value = (_value > 1) ? 1 : _value;
         _value = (_value < 0) ? 0 : _value;
         updateValue( _value );
         if( setControlValue is Function ) {
            setControlValue( _value );
         }
      }

      /**
       * Sets the progress property of this progress control.
       *
       * @param   progress (Number) -  A number from 0 to 1 indicating the percentage this progress is set at.
       **/
      public function setProgress( _progress:Number = -1  )
      {
         if ( progress ) {
            if( _progress <= 1 ) {
               if ( _progress >= 0 ) {
                  progressValue = _progress;
               }
   
               var position:Number = Math.ceil(progressValue * button[_width]);
               progress[_width] = position;
            }
         }
      }

      /**
       * Called when the user presses the progress Button to set the value of this progress control.
       *
       * @param   event (MouseEvent) -  The mouse event of this button press.
       **/
      private function onSetValue( event:MouseEvent )
      {
         setValue( event[_localX] / controlSize );
      }

      /**
       * Called when the user presses down on the progress handle, at which they can drag it back and forth.
       *
       * @param   event (MouseEvent) -  The mouse event of this button press.
       **/
      private function onHandleDown( event:MouseEvent ):void
      {
         dragTimer.start();
			dispatchEvent( new Event( Event.DEACTIVATE ) );
         event.target.startDrag(false, dragRect);
         event.target.addEventListener( MouseEvent.MOUSE_MOVE, onDrag );
      }

      /**
       * Called when the user releases the progress handle.
       *
       * @param   event (MouseEvent) -  The mouse event of this button press.
       **/
      private function onHandleUp( event:MouseEvent ):void
      {
         dragTimer.stop();
			dispatchEvent( new Event( Event.ACTIVATE ) );			
         event.target.stopDrag();
         event.target.removeEventListener( MouseEvent.MOUSE_MOVE, onDrag );
         setValue( dragPercent );
      }

      /**
       * Called on an interval only when the handle is being dragged.
       *
       * @param   event (TimerEvent) -  The timer event which updates at a given interval.
       **/
      private function onDragTimer( e:TimerEvent ):void
      {
			if ( setControlDisp is Function ) {
				setControlDisp( dragPercent );
			} else if ( setControlValue is Function ) {
				setValue( dragPercent );
         }
      }

      /**
       * Called when the user drags the handle back and forth.  Here we will simply cache this mouse
       * position so that it can be set at the dragInterval.
       *
       * @param   event (MouseEvent) -  The mouse event of this operation.
       **/
      private function onDrag(event:MouseEvent):void
      {
         dragPercent = event.target[_x] / controlSize;
      }

      public var handle:Sprite;
      public var button:Sprite;
      public var fullness:Sprite;
      public var progress:Sprite;

      private var _x:String;
      private var _width:String;
      private var _localX:String;

      protected var handleSize:Number;
      protected var controlSize:Number;
      protected var dragTimer:Timer;
      protected var dragRect:Rectangle;
      protected var dragPercent:Number = 0;
      protected var progressValue:Number = 1;
      private var currentValue:Number = 0;
      private var setControlValue:Function;
      private var setControlDisp:Function;		
      private var vertical:Boolean;
   }
}