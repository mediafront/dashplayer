package com.tmtdigital.dash.utils.xml
{
   import com.tmtdigital.dash.utils.Utils;

   // Declare our PlaylistParser class.
   public class PlaylistParser
   {
      /**
       * Translates the XML structure as a "playlist" format to a common data structure for our player to interpret.
       *
       * @param - The actual XML code from the playlist that was just loaded.
       *
       * @return - The translated common data structure for the nodes given in this playlist.
       */
      public static function getPlaylist( xml:XML ) : Array
      {
         var nodes:Array = new Array();

         for each (var _channel in xml.elements()) {
            if ( Utils.getLocalName( _channel ) == "tracklist" ) {
               var commercials:Array = new Array();
               for each (var _track in _channel.elements()) {
                  if ( Utils.getLocalName( _track ) == "track" ) {
                     var newNode:Object = new Object();
                     newNode.nid = 0;
                     newNode.load = false;
                     newNode.files = new Array();
                     var isCommercial:Boolean = false;

                     if (commercials.length > 0) {
                        for each (var commercial:String in commercials) {
                           Utils.addFile( newNode.files, commercial, "commercial" );
                        }

                        commercials = new Array();
                     }

                     for each (var _element in _track.elements()) {
                        var localName:String = Utils.getLocalName( _element );
                     
                        if ( localName == "node" ) {
                           newNode.nid = _element.children().toString();
                           newNode.load = true;
                        } else if ( localName == "title" ) {
                           newNode.title = _element.children().toString();
                        } else if ( localName == "album" ) {
                           isCommercial = (_element.children().toString().toLowerCase() == "commercial");
                        } else if ( ( localName == "location") || ( localName == "image") ) {
                           Utils.addFile( newNode.files, _element.children().toString() );
                        }
                     }

                     if (isCommercial) {
                        for each (var file in newNode.files) {
                           if (file.mediaclass == "media") {
                              commercials.push( file.path );
                           }
                        }
                     } else if ( (newNode.files.length > 0) || (newNode.nid > 0) ) {
                        nodes.push(newNode);
                     }
                  }
               }
            }
         }

         return nodes;
      }
   }
}