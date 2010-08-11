/**
 * MediaPlayer.as - See class description for information.
 *
 * Author - Travis Tidwell ( travist@tmtdigital.com )
 * License - General Public License ( GPL version 3 )
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/
 **/
package com.tmtdigital.dash.display.media
{
	import com.tmtdigital.dash.DashPlayer;
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.events.DashEvent;
   import com.tmtdigital.dash.display.media.Preview;
	import com.tmtdigital.dash.display.media.Spectrum;
   import com.tmtdigital.dash.display.media.VideoPlayer;
   import com.tmtdigital.dash.display.media.AudioPlayer;
   import com.tmtdigital.dash.display.media.MediaState;
   import com.tmtdigital.dash.display.media.controlbar.ControlBar;
   import com.tmtdigital.dash.net.Gateway;
   import com.tmtdigital.dash.config.Params;
   import com.tmtdigital.dash.display.media.Plymedia;
   import flash.events.*;
   import flash.display.*;
   import flash.utils.*;
   import flash.net.*;
   import flash.geom.*;
   import fl.transitions.*;
   import fl.transitions.easing.*;

   /**
    * The Media class is used as a container for all media handling with the dash player. 
    * It is in charge of playing video, audio, and showing preview images.
    */
   public class MediaPlayer extends Skinable
   {
      public static var PLAY:String = "play";
      public static var PAUSE:String = "pause";

      /**
       * Constructor to the MediaPlayer.
       *
       * @param skin - The skin for this media player component.
       */
      public function MediaPlayer( _skin:MovieClip )
      {
         super( _skin );
      }

      /**
       * Called from the Skinable class to set the skin for all of the elements within this MovieClip.
       *
       * @param skin - The skin MovieClip for the playlist.
       */ 
      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );
        
         // Set all of the skin elements.
         video = skin.video;
         mediaRegion = skin.mediaRegion;        
   		spectrum = new Spectrum( skin.spectrum, onSpectrumLoaded );
         preview = new Preview( skin.preview, playFile, postResize );
        
         // Initialize our settings.
         noControls = !Params.flashVars.showcontrols;
         autostart = Params.flashVars.autostart;
         autoload = Params.flashVars.autoload;

         // Initialize the delayTimer.  This timer is used to create a delay before actually playing
         // the media file.  This is so that a person can show the preview image for a certain amount of
         // time before triggering the auto play to kick in.
         delayTimer = new Timer( (Params.flashVars.delay * 1000), 1 );
         delayTimer.addEventListener( TimerEvent.TIMER, onDelayTimer );
         delayTimer.stop();
      }

      /**
       * Initialize the MediaPlayer.
       */
      public function initialize():void
      {
         // Initialize all of our variables.
         playQueue = new Array();
         stopFile();
         delayTimer.reset();
         delayTimer.stop();
			
         if( preview ) {
            preview.unloadPreview();
         }
			
         currentVolume = (currentVolume == -1) ? (Params.flashVars.volume / 100) : currentVolume;
         Gateway.resetControls( noControls );
      }

      /**
       * Connect to the media stream source.
       */
      public function connect()
      {
         if (media) {
            // Add all of our event listeners.
            media.addEventListener( DashEvent.MEDIA_CONNECTED, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_LOADING, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_BUFFERING, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_PAUSED, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_PLAYING, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_STOPPED, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_PROGRESS, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_UPDATE, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_READY, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_COMPLETE, mediaUpdate );
            media.addEventListener( DashEvent.MEDIA_METADATA, mediaUpdate );
           
            // Connect to the media.
            media.connect( loadedFile.stream );
         }
      }

      /**
       * Adds a media file to the play queue.  In order to get the media player to play a file,
       * you must first add that file to the play queue.  You can add many different media to the play queue,
       * which then acts as an internal playlist.
       *
       * @param mediaFile - The media file object ( returned from the Files class ) that will be played.
       */
      public function addMediaToQueue( file:Object ):void
      {
         if( file ) {
            if( file.mediaclass == "media" ) {
               mediaType = file.mediatype;
               mediaFile = file;
            }
        
            playQueue.push( file );
         }
      }

      /**
       * Called to play the next media within the play queue.
       *
       * @return The media player if it is valid.
       */
      public function playNext() : *
      {
         if (playQueue.length > 0) {
            loadMediaFile( playQueue.shift() );
            return media;
         }
         else {
            stopFile();
            return null;
         }
      }

      /**
       * Loads an image preview into the preview component.
       *
       * @param previewFile - The preview file object you wish to load.
       */
      public function loadPreview( previewFile:Object ) : void
      {
         if( previewFile ) {
            if (preview) {
               if( previewFile.path ) {
                  preview.loadPreview( previewFile.path );
               }
               else if( Params.flashVars.image ) {
                  preview.loadPreview( Params.flashVars.image );
               }
            }

            setMediaState( MediaState.STOPPED );        
         }     
      }

      /**
       * Loads the given media file.  You can use this function if you just wish to play a single file.
       *
       * @param mediaFile - The file object you wish to load.
       */
      public function loadMediaFile( file:Object ) : void
      {
         if (file) {
            createMedia( file );
            Gateway.enableControls( ((file.mediaclass != "commercial") && (Params.flashVars.type != "video")), noControls );
         }
      }

      /**
       * Called to load the current media file.
       */
      public function loadFile()
      {
         if (media && autoload) {
            setMediaState( MediaState.LOADING );
            media.loadFile( loadedFile.path );
         }
         else {
            autoload = true;
         }
      }

      /**
       * Stop the media file from playing.
       */
      public function stopFile()
      {
         if (media) {
            media.stop();
         }
      }

      /**
       * Plays the loaded media file.
       *
       * @param checkLoaded - Boolean to see if we should load the media file before playing it.
       */
      public function playFile( checkLoaded:Boolean = true )
      {
         if (media) {
            if (checkLoaded && ! media.loaded) {
               loadMediaFile( loadedFile );
            }
            else {
               dispatchEvent( new DashEvent( DashEvent.MEDIA_PLAYING ) );
               media.playFile( loadedFile.path );
               Gateway.setControlVolume( currentVolume, noControls );
               media.volume = currentVolume;
            }
         }
      }

      /**
       * Pauses the media file.
       */
      public function pauseFile()
      {
         if (media && media.loaded) {
            media.pause();
         }
      }

      /**
       * Sets the seek time of the media.
       *
       * @param seekTime - The time in milliseconds that you would like to seek to.
       */
      public function setSeek( seekTime:Number )
      {
         if (media) {
            seekTime *= (media.totalTime ? media.totalTime : 1);
            media.seek( seekTime );
            Gateway.setControlVolume( currentVolume, noControls );
            media.volume=currentVolume;
         }
      }

      /**
       * Sets the volume of the media being played.
       *
       * @param volume - A number between 0 and 1 to set the volume of the media.
       */
      public function setVolume( vol:Number )
      {
         if (media&&media.loaded) {
            currentVolume=vol;
            media.volume=vol;
         }
      }

      /**
       * Gets the volume of the media being played.
       *
       * @return Number - The current volume of the media being played.
       */
      public function getVolume():Number
      {
         return currentVolume;
      }

      /**
       * Allows you to provide a custom skin to be used as the control bar.
       *
       * @param type - The type of control bara being loaded.  This is passed to the
       * skin so that it can selectively load a given control bar.
       */
      public function setControlBar( type:String ):void
      {
         if (skin) {
            var controlBarSkin:MovieClip = skin.controlBar;
            if (rootSkin.getControlBar is Function) {
               controlBarSkin = rootSkin.getControlBar(type);
               controlBarSkin.x = skin.controlBar.x;
               controlBarSkin.y = skin.controlBar.y;
               var index:Number = skin.getChildIndex(skin.controlBar);
               skin.removeChildAt(index);
               skin.addChildAt(controlBarSkin, index);
            }
            controlBar = new ControlBar(controlBarSkin);
         }
      }

      /**
       * Initialize function that will hide or show certain elements depending on the configuration provided
       * to this player.
       */
      public function hideShow()
      {
         showControls( Params.flashVars.showcontrols );

         if (controlBar && controlBar.skin) {
            controlBar.hideShow();
         }
      }

      /**
       * Returns the currently loaded media file.
       *
       * @return String - The path of the media file currently loaded.
       */
      public function getMediaFile():String
      {
         return loadedFile ? loadedFile.path : "";
      }
      
      /**
       *
       */
      public function getEmbedMediaFile() : String
      {
         return mediaFile ? mediaFile.path : "";
      }
      
      /**
       * Returns the full path of the current media file (if rtmp , then the whole rtmp url)
       *
       * For Plymedia
       *
       * @return String - The path of the media file currently loaded.
       */
      public function getVideoFile():String
      {
         var path:String;
          
         if (loadedFile.stream)
         {
            path = (loadedFile.stream.lastIndexOf("/") == (loadedFile.stream.length-1)) ?
                    loadedFile.stream + loadedFile.path : loadedFile.stream + "/" + loadedFile.path;
         } 
         else
         {
            path = loadedFile.path;
         }
            
         return path;
      }

      /**
       * Called to hide/show the control bar.
       *
       * @param show - If you would like to show (true) the controlBar or not (false).
		 * @param tween - Boolean to indicate if you would like to tween the control bar hide/show movement.
       */
      public function showControls( show:Boolean = true, tween:Boolean = false )
      {
         if ( rootSkin && (rootSkin.showControls is Function) && (controlsShown != show) ) {
            controlsShown = show;
            rootSkin.showControls( show, tween );
         }
      }

      /**
       * Called before the player resizes.  This gives everyone a chance to perform certain tasks before the
       * player is resized.
       */
      public function preResize():void
      {
         if (controlBar && controlBar.skin) {
            controlBar.preResize();
         }
      }

      /**
       * Called after the player resizes.  This gives everyone a chance to perform certain tasks after the 
       * player is resized.
       */
      public function postResize():void
      {
         transitionCounter = 3;
        
         // Resize the media region.
         resizeMediaRegion();

         // Resize the control bar.
         if (controlBar && controlBar.skin) {
            showControls( Params.flashVars.showcontrols );
            controlBar.postResize();
         }
      }

      /**
       * Sets the current display state of the media player.
       *
       * @param state - The display state of the media player.
       * @param showImage - A boolean to indicate if you would like to show the preview image or not.
       */
      private function setMediaState( state:String, _showImage:Boolean = false )
      {
         //trace("MediaState: " + state);
         var showLoader:Boolean = false;
         var playState:Boolean = false;
         var showImage:Boolean = _showImage;
        
         // Switch on the current state.
         switch ( state ) {
            case MediaState.LOADING :
               showLoader = true;
               showImage = true;
               break;
            case MediaState.BUFFERING :
               playState = true;
               showLoader = true;
               break;
            case MediaState.PLAYING :
               playState = true;
               break;
            case MediaState.STOPPED :
               showImage = true;
               break;
            default :
               break;
         }

         showImage = (!media || (media.type != "youtube")) && (showImage || (media.type == "audio"));
         DashPlayer.dash.node.spinner.visible = showLoader;
         setPlayState( playState, showImage );
      }

      /**
       * Called to resize the media region of the player.  This function will resize the media region while
       * at the same time preserve the width and height ratio of the media playing within that region.
       */
      private function resizeMediaRegion()
      {
         if (mediaRegion) {
            var newRect:Rectangle = mediaRegion.getRect(this);

            if ( isVideo() && Params.flashVars.scalevideo ) {
               var mediaRatio:Number = media.ratio;
               if( mediaRatio ) {
                  var videoRect:Rectangle = Utils.getScaledRect( mediaRatio, newRect );
                  media.setSize( videoRect.width, videoRect.height );
                  media.x = videoRect.x;
                  media.y = videoRect.y;
               }
               else {
                  media.setSize( mediaRegion.width, mediaRegion.height );
						media.x = mediaRegion.x;
                  media.y = mediaRegion.y;
               }
               
					if( Params.flashVars.captions ) {
               	plymedia.resize(media.width, media.height, skin.controlBar.height);
               	plymedia.x = media.x;
               	plymedia.y = media.y;
					}
            }

				if( skin.spectrum ) {
					skin.spectrum.width = newRect.width;
					skin.spectrum.height = newRect.height;
				}

            if (preview) {
               preview.postResize( newRect );
            }
				
            if( spectrum ) {
               spectrum.postResize( mediaRegion.width, mediaRegion.height );
            }
         }
      }

      /**
       * Returns if the currently loaded media file is a video.
       *
       * @return Boolean - True => The loaded file is a video, False => The loaded file is not a video.
       */
      private function isVideo() : Boolean
      {
         if( media && ((media.type == "video") || (media.type == "swf") || (media.type == "youtube")) ) {
            return true;
         }
        
         return false;
      }

      /**
       * Called when our delay timer expires.  The delay timer is used to not trigger the auto play to kick in
       * immediately, but rather wait a given interval before triggering the media to play.  This is so that the
       * preview image can be shown for a given period of time before the video plays.
       *
       * @param event - The timer event object of this event.
       */
      private function onDelayTimer( event:TimerEvent )
      {
         delayTimer.stop();
         playFile();
      }

      /**
       * State machine handler of the currently playing media.
       *
       * @param event - The DashEvent object of the event that just occured.
       */
      private function mediaUpdate( e:DashEvent ):void
      {
         switch ( e.type ) {
        
            // The media has just connected to the stream source.
            case DashEvent.MEDIA_CONNECTED :
               loadFile();
					if( Params.flashVars.captions ) {
               	plymedia.setVideo( getVideoFile() );
					}
               break;

            // The media is now playing...
            case DashEvent.MEDIA_PLAYING :
               onMediaPlaying();
               break;

            // The media is buffering...
            case DashEvent.MEDIA_BUFFERING :
               setMediaState( MediaState.BUFFERING );
               break;

            // The media has just been paused ...
            case DashEvent.MEDIA_PAUSED :
					onMediaPaused();
               break;

            // The media is loading ...
            case DashEvent.MEDIA_LOADING :
               onMediaLoading();
               break;

            // The media is ready ...
            case DashEvent.MEDIA_READY :
               onMediaReady();
               break;

            // The media has finished playing ...
            case DashEvent.MEDIA_COMPLETE :
               onMediaComplete();
               break;

            // The media is playing and here is the current play time ...
            case DashEvent.MEDIA_UPDATE :
               if (e.target.loadedFile == loadedFile.path) {
                  onMediaUpdate( e.target.playheadTime, e.target.totalTime );
						if( Params.flashVars.captions ) {
                  	plymedia.updateTime( e.target.playheadTime );
						}
               }
               break;

            // The media is loading and here is the current loaded bytes ...
            case DashEvent.MEDIA_PROGRESS :
               if (e.target.loadedFile == loadedFile.path) {
                  onMediaProgress( e.target.bytesLoaded, e.target.bytesTotal );
               }
               break;

            // The media has just finished loading its meta data ...
            case DashEvent.MEDIA_METADATA :
               onMetaData();
               break;
         }
      }

      /**
       * Triggered when the media starts playing...
       */
      protected function onMediaPlaying()
      {
         autostart = true;
         setMediaState( MediaState.PLAYING );

         if (video) {
            video.visible = true;
         }

         if (rootSkin.onMediaPlaying is Function) {
            rootSkin.onMediaPlaying();
         }
      }
		
		/**
		*Triggerd when the media is paused...
		*/
		protected function onMediaPaused()
		{
			setMediaState( MediaState.PAUSED );
			
			if (rootSkin.onMediaPaused is Function) {
            rootSkin.onMediaPaused();
         }
		}

      /**
       * Triggered when the media starts loading...
       */
      protected function onMediaLoading()
      {
         setMediaState( MediaState.LOADING );

         if (video) {
            video.visible = false;
         }
      }

      /**
       * Triggered when the media is ready to play...
       */
      protected function onMediaReady():void
      {			
         if( !autostart ) {
            autostart = true;
			pauseFile();
			setMediaState( MediaState.STOPPED );
		 }
		 else if( Params.flashVars.delay > 0 ){
			pauseFile();
			delayTimer.start();
		 }

		 onMetaData();
         Gateway.setControlVolume( currentVolume, noControls );
         setVolume( currentVolume );
      }

      /**
       * Triggered when the media has finished playing...
       */
      protected function onMediaComplete():void
      {
         setMediaState( MediaState.STOPPED );

         if (!playNext()) {
            if( autostart && Params.flashVars.autonext ) {
               // See if we need to load the node again...
               if( Params.flashVars.disableplaylist && Params.flashVars.loop ) {
                  Gateway.loadNode();
               }
               else {
                  Gateway.loadNext( true, true, Params.flashVars.disableplaylist );
               }
            }
         }

         if (rootSkin.onMediaComplete is Function) {
            rootSkin.onMediaComplete();
         }
      }

      /**
       * Called continuously while the media is playing to update the play time...
       */
      protected function onMediaUpdate(playheadTime:Number, totalTime:Number)
      {
         if (transitionCounter == 0) {
				if( rootSkin.onMediaUpdate is Function ) {
					rootSkin.onMediaUpdate( playheadTime, totalTime );
				}
				
            Gateway.controlUpdate( playheadTime, totalTime, noControls );
         }
         else {
            transitionCounter--;
         }
      }

      /**
       * Called continuously while the media is loading to update the amount of bytes loaded...
       */
      protected function onMediaProgress( bytesLoaded:Number, bytesTotal:Number ):void
      {
         if (media) {
            var bytesPercent:Number = ( bytesLoaded / bytesTotal );
            Gateway.setControlTime( media.totalTime, noControls );
            Gateway.setControlProgress( bytesPercent, noControls );

            if (media.buffering && media.playing) {
               playFile(false);
            }
         }
      }

      /**
       * Called when the media has finished loading the Meta data...
       */
      private function onMetaData()
      {
         resizeMediaRegion();
         Gateway.setControlTime( media.totalTime, noControls );
      }

      /**
       * Sets the display play state of the media player.  This will show the Play or Pause
       * button depending on if the media is playing or not.
       *
       * @param statePlay - The current play state:  True => media is playing, False => media is stopped.
       * @param showImage - Boolean to tell our preview if it should show the preview image during the stopped state.
       */
      private function setPlayState( statePlay:Boolean, showImage:Boolean )
      {
         if (preview) {
            preview.setPlayState(statePlay, showImage);
         }

         Gateway.setControlState( (statePlay ? PAUSE : PLAY), noControls );
      }

      /**
       * Creates the media object depending on the type of media that was just loaded.
       *
       * @param file - The media file object that was just loaded into this player.
       */
      private function createMedia( file:Object )
      {
         if (file) {
            stopFile();

            // Depending on the type of media that is loaded, we can create the player
            // that knows how to play that media type.
            switch ( file.mediatype ) {
               case "video" :
                  addVideo( new VideoPlayer(mediaRegion.width,mediaRegion.height) );
                  break;

               case "swf" :
                  addVideo( new SWFPlayer() );
                  break;
           
               case "youtube" :
                  addVideo( new YouTubePlayer() );
                  break;
                 
               case "audio" :
                  media = new AudioPlayer(autostart);
                  break;

               case "custom" :
                  if (rootSkin.getMedia is Function) {
                     media = rootSkin.getMedia(file);
                  }
                  break;
            }

            // Store this file as the loaded file.
            loadedFile = file;
           
            // Connect to the media stream.
            connect();
         }
      }

      /**
       * Adds a video player to the display.
       *
       * @param media - The media object that was just created to play the media.
       */
      private function addVideo( _media:* )
      {
         if (video) {
            media = _media;
            Utils.removeAllChildren( video );
            video.addChild( media );
				if( Params.flashVars.captions ) {
            	plymedia = new Plymedia();
            	video.addChild(plymedia);
				}
         }     
      }

      /**
       * Called when the spectrum analyzer has finished loading.
       */
		private function onSpectrumLoaded()
		{
			preview.visible = false;
		}

      /**
       * The media player.
       */
      public static var media:*;
     
      /**
       * The display region to hold the video.
       */
      public var mediaRegion:Sprite;
     
      /**
       * The control bar display object.
       */     
      public var controlBar:ControlBar;
     
      /**
       * The spectrum analyzer.
       */      
		public var spectrum:Spectrum;
		
      /**
       * The display region to hold the preview image.
       */		
      public var preview:Preview;
     
      /**
       * The video display object.
       */     
      public var video:Sprite;
     
      /**
       * The plymedia display object.
       */
      public var plymedia:Plymedia;
     
      /**
       * Boolean to indicate if the control bar is shown or not.
       */
      public var controlsShown:Boolean=true;

      // Private variables.
      private static var noControls:Boolean=false;
      private static var autostart:Boolean=false;
      private static var autoload:Boolean=false;
      private static var mediaType:String = "";
      private static var currentVolume:Number=-1;
      private static var playQueue:Array;
      private static var transitionCounter:uint=0;
      private static var loadedFile:Object;
      private static var mediaFile:Object;
      private static var delayTimer:Timer;
   }
}
