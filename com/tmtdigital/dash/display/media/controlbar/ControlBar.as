/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The Control Bar class is the main control bar for the media region
 * of the Dash Player.  It includes a scrub bar, play pause button, and a volume control bar.
 *
 **/

package com.tmtdigital.dash.display.media.controlbar
{
	import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.FilterList;   
   import com.tmtdigital.dash.display.media.controlbar.SeekBar;
   import com.tmtdigital.dash.display.media.controlbar.VolumeBar;
   import com.tmtdigital.dash.display.media.MediaPlayer;
   import com.tmtdigital.dash.display.controls.ToggleButton;
   import com.tmtdigital.dash.net.Gateway;   
   import com.tmtdigital.dash.config.Params;

   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;

   public class ControlBar extends Skinable
   {
      public static const rewInterval:uint = 250;
      public static const volInterval:uint = 250;
      private static const volDelta:Number = 0.5;

      public function ControlBar( _skin:MovieClip )
      {
         super( _skin );
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );

         controlBarOnly = Params.flashVars.controlbaronly;

         setupButtons();
         rewTimer = new Timer(rewInterval);
         rewTimer.addEventListener( TimerEvent.TIMER, onTimer );
         rewTimer.stop();
         
         // Get the volume interval from our parameters.
         volumeInterval = (Params.flashVars.volumeinterval / 100);
         volTimer = new Timer( volInterval );	
         volTimer.addEventListener( TimerEvent.TIMER, onVolTimer );
         volTimer.stop();

         invalid = skin.invalid;
         playPauseButton = new ToggleButton( skin.playPauseButton, onPlayPause );
         toggleScreen = new ToggleButton( skin.toggleFullScreen, onFullScreen,false );
         minMaxNode = new ToggleButton( skin.minMaxNode,onMinMax, false, Params.showPlaylist );
         menuButton = new ToggleButton( skin.menuButton,onMenu );
         infoButton = new ToggleButton ( skin.infoButton,onInfo );
         volumeBar = new VolumeBar( skin.volumeBar, onSetVolume, (Params.flashVars.volume / 100) );
         seekBar = new SeekBar( skin.seekBar, onSetSeek );
         links = new FilterList( skin.links, controlBarOnly );
      }

      private function setupButtons()
      {
         if ( skin.volumeUp ) {
            volumeUp = skin.volumeUp;
            volumeUp.buttonMode = true;
            volumeUp.mouseChildren = false;
            volumeUp.addEventListener( MouseEvent.MOUSE_DOWN, onVolumeUpPressed );			
            volumeUp.addEventListener( MouseEvent.MOUSE_UP, onVolumeUpReleased );
         }

         if ( skin.volumeDown ) {
            volumeDown = skin.volumeDown;
            volumeDown.buttonMode = true;
            volumeDown.mouseChildren = false;
            volumeDown.addEventListener( MouseEvent.MOUSE_DOWN, onVolumeDownPressed );			
            volumeDown.addEventListener( MouseEvent.MOUSE_UP, onVolumeDownReleased );
         }

         if ( skin.nextButton ) {
            nextButton = skin.nextButton;
            nextButton.buttonMode = true;
            nextButton.mouseChildren = false;
            nextButton.addEventListener( MouseEvent.MOUSE_UP, onNext );
         }

         if ( skin.prevButton ) {
            prevButton = skin.prevButton;
            prevButton.buttonMode = true;
            prevButton.mouseChildren = false;
            prevButton.addEventListener( MouseEvent.MOUSE_UP, onPrev );
         }

         if ( skin.ffButton ) {
            ffButton = skin.ffButton;
            ffButton.buttonMode = true;
            ffButton.mouseChildren = false;
            ffButton.addEventListener( MouseEvent.MOUSE_DOWN, onFFDown );
            ffButton.addEventListener( MouseEvent.MOUSE_UP, onFFUp );
            ffButton.addEventListener( MouseEvent.MOUSE_OUT, onFFUp );
         }

         if ( skin.rewButton ) {
            rewButton = skin.rewButton;
            rewButton.buttonMode = true;
            rewButton.mouseChildren = false;
            rewButton.addEventListener( MouseEvent.MOUSE_DOWN, onRewDown );
            rewButton.addEventListener( MouseEvent.MOUSE_UP, onRewUp );
            rewButton.addEventListener( MouseEvent.MOUSE_OUT, onRewUp );
         }	
      }

      public function showMinMaxButton( _show:Boolean = true )
      {
         if ( (rootSkin.showMinMaxButton is Function) && (minMaxShown != _show) ) {
            minMaxShown = _show;
            rootSkin.showMinMaxButton( _show );
         }
      }

      public function showMenuButton( _show:Boolean = true )
      {
         if ( (rootSkin.showMenuButton is Function) && (menuButtonShown != _show) ) {
            menuButtonShown = _show;
            rootSkin.showMenuButton( _show );
         }
      }
		
		public function showInfoButton( _show:Boolean = true )
      {
         if ( (rootSkin.showInfoButton is Function) && (infoButtonShown != _show) ) {
            infoButtonShown = _show;
            rootSkin.showInfoButton( _show );
         }
      }

      private function onTimer( e:TimerEvent ):void
      {
         playTime += direction;
         Gateway.setSeek( (playTime / totalTime), controlBarOnly );
      }

      private function onVolTimer( e:TimerEvent ) : void
      {
         volCounter++;
         if( volCounter > volDelta ) 
         {
            if( volumeUpPressed ) {
               volume = volume + volumeInterval;
            }
            
            if( volumeDownPressed ) {
               volume = volume - volumeInterval;
            }
            
            volume = (volume>1) ? 1 : volume;
            volume = (volume<0) ? 0 : volume;
            setVolume(volume);
            Gateway.setVolume( volume, controlBarOnly );
         }
      }

      private function onVolumeUpPressed( e:MouseEvent ) : void
      {
         volumeUpPressed = true;
         volTimer.start();
      }
      
      private function onVolumeUpReleased( e:MouseEvent ) : void 
      {
         if( volCounter <= volDelta ) 
         {
            volume = volume + volumeInterval;
            volume = ( volume > 1 ) ? 1 : volume;
            setVolume(volume);
            Gateway.setVolume( volume, controlBarOnly );
         }
         
         volumeUpPressed = false;
         volCounter = 0;
         volTimer.stop();
      }
         
      private function onVolumeDownPressed( e:MouseEvent ) : void
      {			
         volumeDownPressed = true;
         volTimer.start();
      }

      private function onVolumeDownReleased( e:MouseEvent ) : void
      {
         if( volCounter <= volDelta ) 
         {
            volume = volume - volumeInterval;
            volume = (volume < 0) ? 0 : volume;
            setVolume(volume);
            Gateway.setVolume( volume, controlBarOnly );
         }
         
         volumeDownPressed = false;
         volCounter = 0;			
         volTimer.stop();
      }
      
      private function onNext( e:MouseEvent )
      {
         Gateway.loadNext( true, true, Params.flashVars.disableplaylist );
      }

      private function onPrev( e:MouseEvent )
      {
         Gateway.loadPrev( true, true, Params.flashVars.disableplaylist );
      }

      private function onFFDown( e:MouseEvent )
      {
         direction=1;
         rewTimer.start();
      }

      private function onFFUp( e:MouseEvent )
      {
         rewTimer.stop();
      }

      private function onRewDown( e:MouseEvent )
      {
         direction=-1;
         rewTimer.start();
      }

      private function onRewUp( e:MouseEvent )
      {
         rewTimer.stop();
      }

      public function preResize():void
      {
         if ( seekBar.skin ) {
            seekBar.controlActive=false;
         }
      }

      public function postResize():void
      {
         if ( toggleScreen.skin ) {
            toggleScreen.setState( !DashPlayer.fullScreenMode );
            toggleScreen.inProgress=false;
         }

         if ( menuButton && DashPlayer.dash.node && DashPlayer.dash.node.fields ) {
            menuButton.setState( !DashPlayer.dash.node.fields.menu.menuMode );
            menuButton.inProgress=false;
         }

			if ( infoButton && DashPlayer.dash.node && DashPlayer.dash.node.fields ) {
            infoButton.setState( !DashPlayer.dash.node.fields.infoShown );
            infoButton.inProgress=false;
         }
			
         if ( minMaxNode.skin ) {
            minMaxNode.setState( !DashPlayer.maximized );
            minMaxNode.inProgress=false;
         }

         if ( seekBar.skin ) {
            seekBar.postResize();
            seekBar.controlActive=true;
         }
      }

      public function hideShow()
      {
         showMenuButton( !Params.flashVars.disablemenu );
         showMinMaxButton( !Params.flashVars.disableplaylist );
      }

      public function reset()
      {
         setSeekValue(0);
         setProgress(0);
      }

      public function onFullScreen( state:Boolean )
      {
         Gateway.setFullScreen( state, controlBarOnly );
      }
      
      public function onMenu( state:Boolean )
      {
         Gateway.setMenu( state, true, controlBarOnly );
      }
		
      public function onInfo( state:Boolean )
      {
         Gateway.showInfo( state, true, controlBarOnly );
      }
      
      public function onMinMax( state:Boolean )
      {
         Gateway.setMaximize( state, true, controlBarOnly );
      }			

      public function onPlayPause( state:Boolean )
      {
         if (state) {
            Gateway.playMedia(null, controlBarOnly );
         } else {
            Gateway.pauseMedia( controlBarOnly );
         }
      }

      public function setState( state:String )
      {
         if ( playPauseButton.skin ) {
            switch ( state ) {
               case MediaPlayer.PLAY :
                  playPauseButton.setState( true );
                  break;

               case MediaPlayer.PAUSE :
                  playPauseButton.setState( false );
                  break;
            }
         }
      }

      public function enable( _enable:Boolean )
      {
         if ( invalid ) {
            invalid.visible=! _enable;
         }

         if ( seekBar.skin ) {
            seekBar.enable( _enable );
         }
      }

      public function setTotalTime( totalTime:Number )
      {
         if ( seekBar.skin ) {
            seekBar.setTotalTime( totalTime );
         }
      }

      public function update(  _playTime:Number, _totalTime:Number )
      {
         playTime=_playTime;
         totalTime=_totalTime;
         if ( seekBar.skin ) {
            seekBar.update( _playTime, _totalTime );
         }
      }

      public function setSeekValue( _value:Number )
      {
         if ( seekBar.skin ) {
            seekBar.setValue( _value );
         }
      }

      public function setProgress(  percentLoaded:Number )
      {
         if ( seekBar.skin ) {
            seekBar.setProgress( percentLoaded );
         }
      }

      public function onSetSeek( value:Number )
      {
         Gateway.setSeek( value, controlBarOnly );
      }

      public function setVolume( _value:Number = -1 ):void
      {
         volume=_value;

         if ( volumeBar.skin ) {
            volumeBar.updateVolume( _value );
         }
      }

      public function getVolume():Number
      {
         return Gateway.getVolume( controlBarOnly );
      }

      public function onSetVolume( _volume:Number )
      {
         volume=_volume;
         Gateway.setVolume( _volume, controlBarOnly );
      }

      public var invalid:Sprite;
      public var volumeBar:VolumeBar;
      public var seekBar:SeekBar;
      public var playPauseButton:ToggleButton;
      public var toggleScreen:ToggleButton;
      public var minMaxNode:ToggleButton;
      public var menuButton:ToggleButton;
      public var infoButton:ToggleButton;
      public var links:FilterList;
      public var volumeUp:MovieClip;
      public var volumeUpPressed:Boolean=false;
      public var volumeDown:MovieClip;
      public var volumeDownPressed:Boolean=false;
      public var ffButton:MovieClip;
      public var rewButton:MovieClip;
      public var nextButton:MovieClip;
      public var prevButton:MovieClip;
		
      private var direction:Number=1;
      private var volTimer:Timer;
      private var volCounter:Number = 0;
      private var volumeInterval:Number = 0;
      private var rewTimer:Timer;
      private var playTime:Number;
      private var totalTime:Number;
      private var volume:Number;
      private var minMaxShown:Boolean=true;
      private var menuButtonShown:Boolean=true;
		private var infoButtonShown:Boolean=true;
      private var controlBarOnly:Boolean=false;
   }
}