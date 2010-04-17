package com.tmtdigital.dash.utils.xml
{
   import com.tmtdigital.dash.utils.Utils;

   // Declare our ASXParser class.
   public class ASXParser
   {
      /**
       * Translates the XML structure as an "ASX" format to a common data structure for our player to interpret.
       *
       * @param - The actual XML code from the playlist that was just loaded.
       *
       * @return - The translated common data structure for the nodes given in this playlist.
       */
      public static function getPlaylist( xml:XML ) : Array
      {
         var nodes:Array = new Array();

         for each (var _track in xml.elements()) {
            if ( Utils.getLocalName( _track ) == "entry") {
               var newNode:Object = new Object();
               newNode.nid = 0;
               newNode.load = false;
               newNode.files = new Array();

               for each (var _element in _track.elements()) {
                  var localName:String = Utils.getLocalName( _element );
               
                  if ( localName == "node" ) {
                     newNode.nid = _element.children().toString();
                     newNode.load = true;
                  } else if ( localName == "title" ) {
                     newNode.title = _element.children().toString();
                  } else if ( localName == "ref" ) {
                     Utils.addFile( newNode.files, _element.@href.toString() );
                  } else if ( localName == "param" ) {
                     Utils.addFile( newNode.files, _element.@value.toString() );
                  }
               }

               if ( (newNode.files.length > 0) || (newNode.nid > 0) ) {
                  nodes.push(newNode);
               }
            }
         }

         return nodes;
      }
   }
}