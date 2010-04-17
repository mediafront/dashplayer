/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Used as a wrapper class for the functionality of a toggle button - On and Off.
 *
 **/

package com.tmtdigital.dash.display.controls
{
   import com.tmtdigital.dash.display.Skinable;
   
   import flash.display.*;
   import flash.events.*;

   public class ToggleButton extends Skinable
   {
      public function ToggleButton( _skin:MovieClip, callback:Function, _synchronous:Boolean = true, _initState:Boolean = true )
      {
         initState = _initState;
         super( _skin );
         toggleCallback = callback;
         synchronous = _synchronous;
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );
         onButton = skin.onButton;
         offButton = skin.offButton;

         if (onButton) {
            onButton.addEventListener( MouseEvent.MOUSE_UP, onPressed );
         }

         if (offButton) {
            offButton.addEventListener( MouseEvent.MOUSE_UP, offPressed );
         }

         setState( initState );
      }

      /**
       *  Called when the On button has been pressed.
       *
       *  @param - The mouse event from the button press.
       */
      private function onPressed( event:MouseEvent )
      {
         if (event.type == MouseEvent.MOUSE_UP) {
            if ( synchronous || (!inProgress) ) {
               inProgress = true;
               setState( false );
               toggleCallback( true );
            }
         }
      }

      /**
       *  Called when the Off button has been pressed.
       *
       *  @param - The mouse event from the button press.
       */
      private function offPressed( event:MouseEvent )
      {
         if (event.type == MouseEvent.MOUSE_UP) {
            if ( synchronous || (!inProgress) ) {
               inProgress = true;
               setState( true );
               toggleCallback( false );
            }
         }
      }

      /**
       *  Sets the state of this toggle button.
       *
       *  @param - The state of the toggle button.
       */
      public function setState( on:Boolean )
      {
         if( onButton ) {
            onButton.visible = on;
            onButton.buttonMode = on;
            onButton.mouseChildren = ! on;
         }
         
         if( offButton ) {
            offButton.visible = ! on;
            offButton.buttonMode = ! on;
            offButton.mouseChildren = on;
         }
      }

      public var onButton:MovieClip;
      public var offButton:MovieClip;
      public var initState:Boolean = false;
      public var inProgress:Boolean = false;
      public var synchronous:Boolean = true;
      public var toggleCallback:Function;
   }
}