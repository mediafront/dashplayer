package com.tmtdigital.dash.utils.xml
{
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.utils.xml.YouTubeParser;	
   import com.tmtdigital.dash.utils.xml.PlaylistParser;
   import com.tmtdigital.dash.utils.xml.RSSParser;
   import com.tmtdigital.dash.utils.xml.ASXParser;

   // Declare our XMLParser class.
   public class XMLParser
   {
      /**
       * Translates the XML structure to a common data structure for our player to interpret.
       * Currently there is support for XML, ASX, and RSS style playlists.
       *
       * @param - The actual XML code from the playlist that was just loaded.
       */	
      public static function parse( xml:XML ) : Boolean
      {
         switch( Utils.getLocalName( xml ) )
         {
				case "feed":
					playlist = YouTubeParser.getPlaylist( xml );
					return true;
					
            case "playlist":
               playlist = PlaylistParser.getPlaylist( xml );
               return true;
            
            case "rss":
               playlist = RSSParser.getPlaylist( xml );
               return true;
                  
            case "asx":
               playlist = ASXParser.getPlaylist( xml );
               return true;
         }	
         
         return false;
      }
      
      /**
       * Given the page limit and page index, this function returns the playlist
       * object from our XML playlists.
       *
       * @param - The page limit for how many nodes can be given in each page.
       * @param - What page we are currently on.
       *
       * @return - The playlist object used by the player to construct our teasers.
       */
      public static function getPlaylist( _pageLimit:int, _pageIndex:int ) : Object
      {
         var _playlist:Object = new Object();
         _playlist.nodes = new Object();
         _playlist.total_rows = playlist.length;
         var index:int = 0;
         var page:int = 0;

         for each (var node:Object in playlist) {
            if (page == _pageIndex) {
               _playlist.nodes[index] = node;
            }

            index++;
            if ( index >= _pageLimit) {
               page++;
               index = 0;
            }

            if (page > _pageIndex) {
               break;
            }
         }

         return _playlist;
      }		
      
      public static function isReady() : Boolean
      {
         return (playlist.length > 0);
      }
      
      private static var playlist:Array = new Array();		
   }
}