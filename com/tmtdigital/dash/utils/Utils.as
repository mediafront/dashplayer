/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Basic utility class.
 *
 **/

package com.tmtdigital.dash.utils
{
   import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.net.Gateway;
   import com.tmtdigital.dash.config.Params;

   import flash.display.*;
   import flash.geom.*;
   import flash.events.*;
   import flash.net.*;
   import flash.text.*;

   public class Utils
   {
      public static function removeAllChildren(parentMC:DisplayObjectContainer)
      {
         var i:int = parentMC.numChildren;
         while (i--)
         {
            parentMC.removeChildAt(i);
         }
      }

      public static function rand(max:Number):Number
      {
         return Math.round(Math.random() * (max - 1));
      }

      public static function loadXML( _file:String, onLoaded:Function, onError:Function )
      {
         var loader:URLLoader = new URLLoader();
         loader.addEventListener( Event.COMPLETE, onLoaded );
         loader.addEventListener( IOErrorEvent.IO_ERROR, onError );
         var request:URLRequest=new URLRequest(_file);
         request.requestHeaders.push( new URLRequestHeader("pragma", "no-cache") );

         try {
            loader.load( request );
         } catch (error:Error) {
            onError(null);
         }         
      }

      public static function gotoUserWebsite(event:MouseEvent = null)
      {
         navigateToURL(new URLRequest(Params.flashVars.link), '_blank');
      }

      public static function filterPath( path:String, filterPath:String, exceptPath:String = null ):Boolean
      {
         return ((!filterPath || path.indexOf(filterPath) == 0) && (!exceptPath || path.indexOf(exceptPath) != 0));
      }

      public static function getObjectFromPath( refObject:*, _path:String )
      {
         var paths:Array = _path.split(/[\\\/]/);
         paths.shift();
         var obj:* = refObject;

         for each (var path in paths) {
            if (obj.hasOwnProperty(path) && obj[path]) {
               obj = obj[path];
            } else {
               obj = null;
               break;
            }
         }

         if (! obj) {
            trace( "Object not found: " + _path );
         }

         return obj;
      }

      public static function getLocalName( element:XML ) : String
      {
         var elementName:String = (element.localName() as String);
         if( elementName ) {
            return elementName.toLowerCase();
         }
         return "";
      }

      public static function getScaledRect( ratio:Number, rect:Rectangle ):Rectangle
      {
         var scaledRect:Rectangle = new Rectangle(rect.x,rect.y,rect.width,rect.height);

         if (ratio) {
            var newRatio:Number = (rect.width / rect.height);
            scaledRect.height = (newRatio > ratio) ? rect.height : Math.floor(rect.width / ratio);
            scaledRect.width = (newRatio > ratio) ? Math.floor(rect.height * ratio) : rect.width;
            scaledRect.x = Math.floor((rect.width - scaledRect.width) / 2);
            scaledRect.y = Math.floor((rect.height - scaledRect.height) / 2);
         }

         return scaledRect;
      }

      public static function getMediaFile( file:Object ):Object
      {
         var mediaFile:Object = new Object();
         mediaFile.stream = Params.flashVars.streamer ? Params.flashVars.streamer : file.stream;
         mediaFile.path = file.filepath ? ( Params.baseURL + "/" + trim(file.filepath) ) : trim(file.path);
         mediaFile.extension = file.extension ? file.extension : getFileExtension(mediaFile.path);
         mediaFile.filename = file.filename ? file.filename : getFileName(mediaFile.path);
         
         var mediaType:String = getMediaType(mediaFile.extension);
         if( !mediaType ) {
            file.mediatype = Params.flashVars.type ? Params.flashVars.type : file.mediatype;
         }
         
         mediaFile.mediatype = file.mediatype ? file.mediatype : getMediaType(mediaFile.extension);
         mediaFile.weight = file.weight ? file.weight : getMediaWeight(mediaFile.extension);
         mediaFile.mediaclass = file.mediaclass ? file.mediaclass : getMediaClass(mediaFile.mediatype);
         return (mediaFile.mediatype == "") ? null : mediaFile;
      }

      /**
       * Adds a single file to a files array.
       *
       * @param - The files array in which to add this file too.
       * @param - The path of the file to be added.
       * @param - The media class of this file to be added.
       */
      public static function addFile( files:Array, _path:String, _class:String = null )
      {
         if (_path) {
            var newFile = getMediaFile( {path:_path,mediaclass:_class} );
            if (newFile) {
               files.push( newFile );
            }
         }
      } 

      public static function getFileName( _file:String ):String
      {
         if( _file ) {
            var paths:Array = _file.split(/[\\\/]/);
            return paths[(paths.length - 1)];
         }
         else {
            return "";
         }
      }

      public static function trim(str:String):String  
      {  
         if( str ) {
            for(var i:Number = 0; str.charCodeAt(i) < 33; i++);  
            for(var j:Number = str.length-1; str.charCodeAt(j) < 33; j--);  
            return str.substring(i, j+1);  
         }
         return "";
      }

      public static function getFileExtension( _file:String ):String
      {
         var extension:String = "";
         
         if( _file ) {
            if( _file.indexOf("rtmp://") >= 0 ) {
               extension = "rtmp";
            }
            else {
               extension = _file.substring(_file.lastIndexOf(".") + 1);
            }
         }
         
         return extension.toLowerCase();
      }

      public static function getMediaClass( mediaType:String ):String
      {
         if( mediaType ) {
            return ((mediaType == "image") ? "image" : "media");
         }
         else {
            return "";
         }
      }

      public static function getMediaWeight( _extension:String ):uint
      {
         if( _extension ) {
            switch ( _extension ) {
               case "mov" :
                  return (Params.flashVars.flashonly ? 100 : 0);

               case "mp4" :
               case "m4v" :
                  return (Params.flashVars.flashonly ? 101 : 1);

               case "flv" :
                  return 2;

               case "rtmp" :
               case "3g2" :
                  return 3;

               case "mp3" :
               case "m4a" :
               case "aac" :
               case "ogg" :
               case "pls" :
               case "m3u" :
                  return 4;

               case "aif" :
               case "wma" :
                  return 5;

               case "wav" :
                  return 6;

               case "png" :
                  return 7;

               case "jpg" :
                  return 8;

               case "gif" :
                  return 9;
            }
         }

         return 10;
      }

      public static function getMediaType( extension:String ):String
      {
         switch( extension )
         {
            case "flv":
            case "rtmp":
            case "mp4":
            case "m4v": 
            case "mov":
            case "3g2":
               return "video";
					
            case "mp3":				
            case "m4a":
            case "aac": 
            case "ogg":
            case "wav":
            case "aif":
            case "wma":				
               return "audio";
					
            case "jpg":
            case "gif": 
            case "png":
               return "image";
					
            default:
               return "";		
         }
      }
   }
}