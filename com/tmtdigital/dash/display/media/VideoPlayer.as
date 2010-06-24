package com.tmtdigital.dash.display.media
{
   import com.tmtdigital.dash.events.DashEvent;
   import com.tmtdigital.dash.display.media.IMedia;
   import com.tmtdigital.dash.config.Params;
   import com.tmtdigital.dash.utils.Utils;

   import flash.media.Video;
   import flash.media.SoundTransform;
   import flash.media.SoundMixer;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.utils.*;

   public class VideoPlayer extends Video implements IMedia
   {
      public function VideoPlayer( _width:uint, _height:uint )
      {
         super(_width,_height);
      }

      public function connect( _stream:String ) : void
      {
         SoundMixer.stopAll();
         _playing = false;
         connection = new NetConnection();
         connection.objectEncoding = flash.net.ObjectEncoding.AMF0;
         connection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler );
         connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
         connection.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR,errorHandler);
         connection.client = this;			
         _stream =  (_stream == "") ? null : _stream;
         _usingStream = ((_stream != null) || (Params.flashVars.type == "video"));
         //trace("Debug: Connected");
         connection.connect( _stream );
      }

      private function setupVideoStream()
      {	
         stream = new NetStream(connection);
         stream.addEventListener(NetStatusEvent.NET_STATUS,statusHandler);
         stream.addEventListener(IOErrorEvent.IO_ERROR,errorHandler);
         stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
         stream.bufferTime = Params.flashVars.bufferlength;
         stream.client = this;

         sound = new SoundTransform();
         stream.soundTransform = sound;
         super.attachNetStream(stream);
         smoothing = true;
         deblocking = 3;
         connected = true;
         //trace("Debug: Setup Client");
         dispatchEvent( new DashEvent( DashEvent.MEDIA_CONNECTED ) );
      }

      private function errorHandler(event:ErrorEvent):void
      {
         trace("Error: " + event.text);
      }

      private function playStream( file:String )
      {
         //trace("Debug: Play Stream");
         if (stream != null) {
            try {
               _playing = true;
               SoundMixer.stopAll();
               stream.play(file);
            } catch (error:Error) {
               trace(error);
               _playing = false;
               return;
            }
         }
      }

      private function seekStream( pos:Number )
      {
         //trace("Debug: Seek Stream " + pos);
         if (stream != null) {
            try {
               stream.seek( pos );
            } catch (error:Error) {
               trace(error);
               return;
            }
         }
      }

      private function pauseStream()
      {
         //trace("Debug: Pause Stream");
         if (stream != null) {
            try {
               _playing = false;
               stream.pause();
            } catch (error:Error) {
               trace(error);
               return;
            }
         }
      }

      private function resumeStream()
      {
         //trace("Debug: Resume Stream");
         if (stream != null) {
            try {
               _playing = true;
               stream.resume();
            } catch (error:Error) {
               trace(error);
               _playing = false;
               return;
            }
         }
      }

      public function closeStream()
      {
         //trace("Debug: Closing Stream");
         _loaded = false;
         _playing = false;
         SoundMixer.stopAll();
         clearInterval(loadInterval);
         clearInterval(timeInterval);

         if( stream ) {
            stream.removeEventListener(NetStatusEvent.NET_STATUS,statusHandler);
            stream.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
            stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);		
            stream.close();			
         }
         
         if( connection ) {
            connection.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler );
            connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,errorHandler);
            connection.removeEventListener(IOErrorEvent.IO_ERROR,errorHandler);
            connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,errorHandler);				
            connection.close();
         } 
      }

      private function loadHandler()
      {
         if( stream ) {
            var loadedPercent:Number = stream.bytesLoaded / stream.bytesTotal;

            if ( (stream != null) && (loadedPercent>=1) ) {
               setReady();
               clearInterval(loadInterval);
            }
            
            if( !_buffering ) {
               dispatchEvent( new DashEvent( DashEvent.MEDIA_PROGRESS ) );
            }
         }
      }

      public function set volume(vol:Number) : void
      {
         if( sound && stream ) {
            sound.volume = vol;
            stream.soundTransform = sound;
         }
      }

      public function onMetaData(info:Object)
      {
         _totalTime = info.duration;
         _videoWidth = info.width;
         _videoHeight = info.height;
         dispatchEvent( new DashEvent( DashEvent.MEDIA_METADATA ) );
         if( !_usingStream ) {
            setReady();
         }			
      }

      public function onPlayStatus(info:Object) 
      {
         if( info.code == "NetStream.Play.Complete" ) {
            clearInterval(timeInterval);
            dispatchEvent( new DashEvent( DashEvent.MEDIA_COMPLETE ) );
         }		
      }
      
      public function onCuePoint(info:Object) {}
      public function onXMPData(info:Object) {}
      public function onTextData(info:Object) {}
      public function onCaptionInfo(info:Object) {}
      public function onCaption(cps:String,spk:Number) {}
      public function onLastSecond(info:Object){}

      private function timeHandler()
      {			
         if( _playing && !_videoWidth && videoWidth ) {
            _videoWidth = videoWidth;
            _videoHeight = videoHeight;
            dispatchEvent( new DashEvent( DashEvent.MEDIA_METADATA ) );
         }
		
         if ( (stream != null) && (stream.time > 0) ) {
            dispatchEvent( new DashEvent( DashEvent.MEDIA_UPDATE ) );
         }
      }

      public function loadFile( file:String ) : void
      {
         dispatchEvent( new DashEvent( DashEvent.MEDIA_LOADING ) );
         _totalTime = 0;
         _videoWidth = 0;
         _videoHeight = 0;         
         _loadedFile = file;			
         loadInterval = setInterval(loadHandler,100);
         timeInterval = setInterval(timeHandler,100);
         
         //trace("Debug: Load");
         var fileName:String = getFileName(file);
         
         if( _usingStream ) {
            var res:Responder = new Responder( streamlengthHandler );
            connection.call( "getStreamLength", res, fileName );
         }			
         
         playStream( fileName );
      }
      
      private function getFileName( fileName:String ):String {
         
         if( _usingStream ) {
            var ext:String = Utils.getFileExtension(fileName)
            if(ext == 'mp3') {
               return 'mp3:'+fileName.substr(0,fileName.length-4);
            } else if(ext == 'mp4' || ext == 'mov' || ext == 'aac' || ext == 'm4a') {
               return 'mp4:'+fileName;
            } else if (ext == 'flv') {
               return fileName.substr(0,fileName.length-4);
            } 
         }
         
         return fileName;
      }		
      
      private function streamlengthHandler(len:Number):void {
         _totalTime = len;
         dispatchEvent( new DashEvent( DashEvent.MEDIA_METADATA ) );				
      }

      public function playFile( _file:String ) : void
      {
         //trace("Debug: Play");
         resumeStream();
         timeInterval = setInterval(timeHandler,100);
         
         if( !_usingStream ) {
            dispatchEvent( new DashEvent( DashEvent.MEDIA_PLAYING ) );
         }
      }

      public function pause() : void
      {
         //trace("Debug: Pause");
         clearInterval(timeInterval);
         pauseStream();
         
         if( !_usingStream ) {
            dispatchEvent( new DashEvent( DashEvent.MEDIA_PAUSED ) );
         }
      }

      public function stop() : void
      {
         //trace("Debug: Stop");
         _loaded = false;
         closeStream();
         dispatchEvent( new DashEvent( DashEvent.MEDIA_STOPPED ) );
      }

      public function seek( pos:Number ) : void
      {
         //trace("Debug: Seek " + pos);		
			if( _loaded ) {
			   if( !_usingStream ) {
               var loadedPercent:Number = stream.bytesLoaded / stream.bytesTotal;
				   var seekPercent:Number = pos / _totalTime;
				   if( seekPercent > loadedPercent ) {
					   pos = (_totalTime * loadedPercent) - 3;
				   }
			   }
				if( pos > 0 ) {
               seekStream( pos );
				}
			}
      }

      public function get totalTime():Number
      {
         return _totalTime;
      }

      public function get playheadTime():Number
      {		
         return (stream != null) ? stream.time : 0;
      }

      public function get bytesTotal()
      {
			if( _usingStream ) {
				return stream.bytesLoaded;
			}
			else {
         	return ( stream == null ) ? 1 : stream.bytesTotal;
			}
      }

      public function get bytesLoaded()
      {
         return ( stream == null ) ? 0 : stream.bytesLoaded;
      }

      private function statusHandler(event:NetStatusEvent)
      {
         //trace("Debug: " + event.info.code );
         switch ( event.info.code ) {
            case "NetConnection.Connect.Success" : 
               setupVideoStream();
               break;
               
            case "NetStream.Seek.Notify":
               if( _usingStream ) {
                  _buffering = true;
                  dispatchEvent( new DashEvent( DashEvent.MEDIA_BUFFERING ) );
               }
               break;
               
            case "NetStream.Buffer.Empty":		
               _buffering = true;
               dispatchEvent( new DashEvent( DashEvent.MEDIA_BUFFERING ) );
               break;
      
            case "NetStream.Buffer.Full":
			   _buffering = false;
               dispatchEvent( new DashEvent( DashEvent.MEDIA_PLAYING ) );
               if( _usingStream ) {
                  setReady();
               }
               break;
      
            case "NetStream.Pause.Notify":
               if( _usingStream ) {
                  dispatchEvent( new DashEvent( DashEvent.MEDIA_PAUSED ) );
               }
               break;
   
            case "NetStream.Play.Start" :
               if( _usingStream ) {
                  _buffering = true;
                  dispatchEvent( new DashEvent( DashEvent.MEDIA_BUFFERING ) );
               }
               break;

            case "NetStream.Play.Stop" :
               if ( !_usingStream && (stream.bytesTotal == stream.bytesLoaded) ) {
                  clearInterval(timeInterval);
                  dispatchEvent( new DashEvent( DashEvent.MEDIA_COMPLETE ) );
               }
               break;

            case "NetStream.Play.StreamNotFound" :
               stop();
               break;

            default :
               break;
         }
      }

      private function setReady() 
      {
         if( !_loaded ) {
            if( !_totalTime && stream ) {
               _totalTime = (( stream.bytesTotal / stream.bytesLoaded ) * stream.bufferLength) / 100;		
            }
                        
            //trace("Debug: Ready!");				
            _loaded = true;
            dispatchEvent( new DashEvent( DashEvent.MEDIA_READY ) );
            return true;
         }
         
         return false;		
      }

      public function setSize( _width:Number, _height:Number )
      {
         this.width = _width;
         this.height = _height;
      }

      public function get ratio():Number
      {
         return (videoWidth) ? (videoWidth / videoHeight) : (_videoWidth / _videoHeight);
      }

      public function get type():String
      {
         return "video";
      }
      
      public function get loaded():Boolean
      {
         return _loaded;
      }
      
      public function get loadedFile():String
      {
         return _loadedFile;
      }		

      public function get playing() : Boolean
      {
         return _playing;
      }
      
      public function get buffering() : Boolean
      {
         return _buffering;
      }		

      private var connected:Boolean = false;
      private var connection:NetConnection = null;

      private var stream:NetStream = null;
      private var _buffering:Boolean = false;
      private var sound:SoundTransform;
      private var timeInterval:Number;
      private var loadInterval:Number;
      private var _totalTime:Number = 0;
      private var _loaded:Boolean = false;
      private var _loadedFile:String = "";		
      private var _playing:Boolean = false;
      private var _usingStream:Boolean = false;
      private var _videoWidth:Number = 0;
      private var _videoHeight:Number = 0;
   }
}