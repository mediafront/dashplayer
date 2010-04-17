/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Used to manage the file lists within each node of the Dash Player.
 *
 **/

package com.tmtdigital.dash.utils
{
   import com.tmtdigital.dash.net.Service;
   import com.tmtdigital.dash.utils.Utils;

   public class Files
   {
      public function Files( _node:Object )
      {			
         // Initialize our files array.
         files = new Array();
         hasImage = false;
         hasMedia = false;
      
         if ( _node ) {			
            // Merge the Service files.
            for each( var file:Object in Service.files ) {
               setMediaFlags( file );
               files.push( file );
            }	
            
            // Add the custom media field.
            if( _node.hasOwnProperty("field_dashplayer_media") ) {
               addMediaFile( {path:_node["field_dashplayer_media"][0]["value"], weight:-1} );
            }
            
            // Add the custom image field.
            if( _node.hasOwnProperty("field_dashplayer_image") ) {
               addMediaFile( {path:_node["field_dashplayer_image"][0]["value"], weight:-1} );
            }
            
            // Search for the files.
            searchForFiles( _node );
            
            // Sort the files based on the weight of each file.
            files.sort( sortWeight );
         }
      }

      private function searchForFiles( _node:* )
      {
         for( var fieldName:* in _node ) { 
            if( (fieldName == "filepath") || (fieldName == "filename") ) {
               addMediaFile( _node );
					break;
            }
            else {
               searchForFiles( _node[fieldName] );
            }
         }
      }

      private function setMediaFlags( mediaFile:Object )
      {
         hasMedia = hasMedia ? true : ( mediaFile.mediaclass=="media" );
         hasImage = hasImage ? true : ( mediaFile.mediaclass=="image" );
      }

      private function addMediaFile( _file:Object )
      {
         var mediaFile:Object = Utils.getMediaFile( _file );
         if ( mediaFile ) {
            setMediaFlags( mediaFile );
            files.push( mediaFile );
         }
      }

      public function getFile( mediaclass:String, fileId:String = null ):Object
      {
         return search( mediaclass, fileId );
      }

      private function search( mediaclass:String, fileId:String ):Object
      {
         for each (var file:Object in files) {
            if ( isCorrectFile( file, mediaclass, fileId ) ) {
               return file;
            }
         }
         return null;
      }

      private function isCorrectFile( file:Object, mediaclass:String, fileId:String ):Boolean
      {
         if( file.mediaclass == mediaclass ) {
            if( !fileId || (fileId == mediaclass) || ( fileId == ("image_" + file.filename) ) ) {
               return true;
            }
         }
         return false;
      }
      
      private function sortWeight( a:Object, b:Object ) : Number
      {
          if( a.weight > b.weight ) {
              return 1;
          } else if( a.weight < b.weight ) {
              return -1;
          } 
          return 0;
      }      

      private var files:Array;
      public var hasImage:Boolean;
      public var hasMedia:Boolean;
   }
}