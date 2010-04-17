/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The seek bar is used as a scrub bar for the video or audio
 * in the media player.
 *
 **/

package com.tmtdigital.dash.display.media.controlbar
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.controls.ProgressControl;
   import com.tmtdigital.dash.config.Params;

   import flash.display.*;
   import flash.text.*;
	import flash.events.*;

   public class SeekBar extends Skinable
   {
      public function SeekBar( _skin:MovieClip, _setControlSeek:Function )
      {
         super( _skin );
         setControlSeek = _setControlSeek;
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );
         playTime = skin.playTime;
         totalTime = skin.totalTime;
         timeUnits = skin.timeUnits;
			totalTimeValue = 0;
			controlActive = true;
			
         control = new ProgressControl( skin.control, onSetValue, setPlayDisp, Params.flashVars.seekvertical );
			control.addEventListener( Event.ACTIVATE, onControlActivate );
			control.addEventListener( Event.DEACTIVATE, onControlActivate );
      }

		public function onControlActivate( e:Event )
		{
			controlActive = ( e.type == Event.ACTIVATE );
		}

      public function postResize()
      {
         if (control) {
            control.postResize();
         }
      }

      public function setProgress(  percentLoaded:Number )
      {
         if (control) {
            control.setProgress( percentLoaded );
         }
      }

      public function enable( _enable:Boolean )
      {
         if (control) {
            control.enableButton( _enable );
            control.enableHandle( _enable );
         }
      }

      public function setTotalTime( _time:Number )
      {
			totalTimeValue = _time;
         if (totalTime) {
            var mediaTime:Object = formatTime(_time);
            totalTime.text = mediaTime.time;
            
            if( timeUnits ) {
               timeUnits.text = mediaTime.units;
            }
         }
      }

		public function setPlayTime( _playTime:Number )
		{
         if (playTime) {
            var mediaTime:Object = formatTime(_playTime);
            playTime.text = mediaTime.time;
         }			
		}

      public function update(  playHeadTime:Number, _totalTime:Number )
      {
			// Set the total time.
			setTotalTime( _totalTime );	
			
         if( controlActive ) {
            setPlayTime( playHeadTime );
            if (control) {
               control.updateValue((playHeadTime / _totalTime));
            }
         }
      }

      public function setValue( _value:Number )
      {
         if (control) {
            control.updateValue( _value );
         }
      }

		public function setPlayDisp( _value:Number ) 
		{
			setPlayTime( _value * totalTimeValue );
		}

      public function onSetValue( _value:Number = -1 ):void
      {
         setControlSeek( _value );
      }

      private function formatTime(mediaTime:Number):Object
      {
         if (rootSkin.formatTime is Function) {
            return rootSkin.formatTime( mediaTime );
         }

         return {time:"", units:""};
      }

      public var playTime:TextField;
      public var totalTime:TextField;
      public var timeUnits:TextField;
		public var totalTimeValue:Number;
      public var controlActive:Boolean;
      public var control:ProgressControl;
      public var setControlSeek:Function;
   }
}