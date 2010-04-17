/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The volume bar within the control bar of the media region.  This is used
 * to control the volume of the media being played.
 *
 **/

package com.tmtdigital.dash.display.media.controlbar
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.controls.ProgressControl;
   import com.tmtdigital.dash.display.controls.ToggleButton;
   import com.tmtdigital.dash.config.Params;
   
   import flash.events.*;
   import flash.display.*;

   public class VolumeBar extends Skinable
   {
      public function VolumeBar( _skin:MovieClip, _setControlVolume:Function, _volume:Number )
      {
         super( _skin );
         setControlVolume = _setControlVolume;
         volume = _volume;
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );
         control = new ProgressControl( skin.control, onSetValue, null, Params.flashVars.volumevertical );
         control.updateValue( volume );
         control.setProgress( 1 );
         muteToggle = new ToggleButton( skin.muteToggle, onToggle, true, (volume > 0) );
         control.updateValue( volume );
      }

      /**
          * Called to actually update the volume without setting control bar parent value.
          *
          * @param - The value to set the volume too (1 - MAX, 0 - MIN)
          */
      public function updateVolume( _value:Number = -1 ):void
      {
         lastVolume = _value;

         if ( muteToggle.skin ) {
            muteToggle.setState( (_value == 0) );
         }

         if ( control.skin ) {
            control.updateValue( _value );
         }
      }

      /**
          * Called when the user actually sets the value.  Here we will make a call to the parent 
          * to set the volume.
          *
          * @param - The value that the user set the volume too.  (1 - MAX, 0 - MIN)
          */
      public function onSetValue( _value:Number = -1 ):void
      {
         if (! fromToggle) {
            lastVolume = _value;

            if ( muteToggle.skin ) {
               muteToggle.setState( (_value == 0) );
            }
         }

         fromToggle = false;
         setControlVolume( _value );
      }

      /**
       *  Called when the mute toggle button has been pressed.
       *
       *  @param - The state of the toggle button after it was pressed.
       */
      public function onToggle( state:Boolean )
      {
         fromToggle = true;

         if ( control.skin ) {
            control.setValue( (state) ? lastVolume : 0 );
         }
         else {
	        setControlVolume( (state) ? lastVolume : 0 );
         }
      }

      public var fromToggle:Boolean = false;
      public var muteToggle:ToggleButton;
      public var control:ProgressControl;
      private var lastVolume:Number = 0;
      public var setControlVolume:Function;
      private var volume:Number = 0;
   }
}