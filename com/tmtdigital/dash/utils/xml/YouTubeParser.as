package com.tmtdigital.dash.utils.xml
{
   import com.tmtdigital.dash.utils.Utils;

   // Declare our YouTubeParser class.
   public class YouTubeParser
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
            if ( Utils.getLocalName( _channel ) == "entry" ) {
               
					var newNode:Object = new Object();
               newNode.nid = 0;
               newNode.load = false;
               newNode.files = new Array();						
					
					for each (var _track in _channel.elements()) {
						
                  if ( Utils.getLocalName( _track ) == "content" ) {
							var newFile:Object = new Object();						
							
							var content:String = _track.children().toString();
							var imgRegEx:RegExp=/(<img.*src=")(?P<image>([^"]+))/;
							var imgObj:Object = imgRegEx.exec(content) as Object;
							var image:String = (imgObj) ? imgObj.image : "";
							if( image ) {
								Utils.addFile( newNode.files, image, "image" );
							}			
							
							var vidRegEx:RegExp=/(<a.*href=")(?P<video>([^"]+))/;
							var videoObj:Object = vidRegEx.exec(content) as Object;
							var video:String = (videoObj) ? videoObj.video : "";
							if( video ) {
								newFile = Utils.getMediaFile( {path:video,filename:"youtube",mediatype:"youtube"} );
            				if (newFile) {
               				newNode.files.push( newFile );
           					}								
							}							
                  }
						else if( Utils.getLocalName( _track ) == "title" ) {
							newNode.title = _track.children().toString();
						}
               }
					
               if ( newNode.files.length > 0 ) {
                  nodes.push(newNode);
               }						
            }
         }

         return nodes;
      }
   }
}