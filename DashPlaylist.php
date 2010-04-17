<?php
require_once("DashUtils.php");

/**
 * Dash Playlist Class
 *
 * License:    GPL
 * Author:     Travis Tidwell    (www.travistidwell.com)
 * Copyright:  TMT Digital 2008  (www.tmtdigital.com)
 *
 * This class is used to generate and cache a playlist using common directory structure.  
 * It works by searching through the playlists directory for a series of directories used to generate a playlist (the default is called "default"), 
 * and then populating the XML tracklist based on the directories which hold the media in the playlist.  Each directory
 * can hold a video or audio track along with an image used as the thumbnail and album art.  The directories inside each playlist directory
 * should be labeled "track" followed by the playlist number of the item to play in the player. 
 *
 * For example, if you wish to have a playlist with 3 different songs with their respective album art, your directory 
 * structure might look like the following...
 *
 *    playlists
 *       - default
 *          - track1
 *             - Jack Johnson - Good People.mp3
 *             - AlbumArt.jpg
 *          - track2
 *             - 311 - Amber.mp3
 *             - AlbumArt.jpg
 *          - track3
 *             - Modest Mouse - Missed the Boat.mp3
 *             - AlbumArt.jpg
 *
 * Once this class builds the playlist, it then caches it by creating an XML file on your server so that each subsequent
 * request for the same playlist will only dump the contents of a file rather than search through directories.
 *
 * Example: To print out a playlist called "myplaylist", you would use the following PHP.
 *
 *    <?php
 *       $playlist = new DashPlaylist( 'myplaylist' );
 *       $playlist->show();
 *    ?>
 *
 *    This code will then look inside the "playlists/myplaylist" directory for a series of directories to define a playlist,
 *    and return that in XML form to be used by any common player, including the Dash Media Player.
 *
 */

class DashPlaylist
{
   private $schema;
   private $playlist;
   private $mediaTypes = array('flv', 'rtmp', 'mp4', 'm4v', 'mov', '3g2', 'mp3', 'm4a', 'aac', 'ogg', 'wav', 'aif', 'wma');
   private $imageTypes = array('jpg', 'gif', 'png');
   private $folderLength = 5;    // The number of characters in "track"...
   private $cache = TRUE;    
   
   /**
    * Constructor
    *
    * @param - The playlist to generate and cache.
    * @param - The XML schema to use when generating and caching the playlist.
    */
   
   public function DashPlaylist( $_playlist = 'default', $_schema = 'xml' )
   {
      $this->playlist = $_playlist;
      $this->schema = $_schema;
   }
   
   /**
    * If you would like to use caching or not.
    *
    * @param - TRUE - use caching,  FALSE - do not use caching.
    */   
   
   public function useCache( $_cache )
   {
      $this->cache = $_cache;  
   }
   
   /**
    * Clears the cache by simply deleting the generated XML file.
    */   
   
   public function clearCache()
   {
      unlink( getcwd() . '/cache/' . $this->playlist . '.xml' );
   }
   
   /**
    * Allows you to set the media types used by this class when searching for media files.
    *
    * @param - An array of extensions to look for when searching for media files.
    */    
   
   public function setMediaTypes( $_mediaTypes )
   {
      $this->mediaTypes = $_mediaTypes;
   }
   
   /**
    * Allows you to set the image types used by this class when searching for image files.
    *
    * @param - An array of extensions to look for when searching for image files.
    */    
   
   public function setImageTypes( $_imageTypes )
   {
      $this->imageTypes = $_imageTypes;
   }      
   
   /**
    * Prints the playlist on the screen.
    */     
   public function show()
   {
      print $this->getPlaylist();
   }
   
   /**
    * Returns the playlist in XML form.
    *
    * @return - The XML format of the playlist.
    */   
   public function getPlaylist()
   {
      // Initialize some variables.
      $xml = '';
      $path = getcwd();
      $playlist_dir = $path . '/playlists/' . $this->playlist;   
      $playlist_file = $path . '/cache/' . $this->playlist . '.xml';
   
      // If there is already a cache file, then we will just want to use it.
      if( $this->cache && file_exists($playlist_file) ) 
      {
         // Open the cache file and populate the XML variable with its contents.
         $handle = fopen( $playlist_file, "r");
         if( $handle )
         {  
            while (!feof($handle)) {
               $xml .= fgets($handle, 4096);
            }
            
            fclose( $handle );
         }
      }
      else if( is_dir($playlist_dir) )
      {
         // Here we will want to search for all the media files and their images for the playlist.
         $contents = '';
         $files = array();
         $this->get_media_files( $playlist_dir, $files);
         if( $files )
         {
            $url = dash_base_url();
            $numfiles = count($files);
            
            // Iterate through all the files.
            for( $i=0; $i < $numfiles; $i++ )
            {               
               $file = $files[$i];               
               $image = '';
               
               // If there is an image association.     
               if( isset($file['image']) && $file['image'] ) 
               {
                  // Set the image variable to be used later.
                  $image = str_replace($path, '', $file['image']);
                  $image = htmlspecialchars($url . $image);               
               }       
               
               // If there is a media file.
               if( isset($file['media']) && $file['media'] )
               {
                  // Iterate through all the media files in this directory.
                  foreach($file['media'] as $media) 
                  {
                     $media = str_replace($path, '', $media);
                     $media = htmlspecialchars($url . $media);
                              
                     // Set the contents of this single track listing with
                     // its associated image file.
                     switch( $this->schema )
                     {
                        case 'rss':
                           $contents .= $this->rssGetTrack( $media, $image );
                           break;
                        case 'asx':
                           $contents .= $this->asxGetTrack( $media, $image );
                           break;
                        case 'xml':
                        default:
                           $contents .= $this->playlistGetTrack( $media, $image );
                           break;                        
                     }
                  }
               }      
            }
         }
            
         // Now, set up the whole XML structure given the right schema.
         if( $contents )
         {
            switch( $this->schema )
            {
               case 'rss':
                  $xml = $this->getRSSXML( $contents );
                  break;
               case 'asx':
                  $xml = $this->getASXXML( $contents );
                  break;
               case 'xml':
               default:
                  $xml = $this->getPlaylistXML( $contents );
                  break;
            }
         }
         
         // Now, let's create our cache file.
         if( $this->cache )
         {   
            $handle = fopen( $playlist_file, "w");
            if( $handle )
            {         
               fwrite( $handle, $xml );
               fclose( $handle );
            }
         }
      }  
      
      // Return the XML structure.
      return $xml;   
   }
   
   /**
    * Gets the file extension of any given file..
    *
    * @return - The file to get the extension of.
    */ 
   private function get_file_ext($file) 
   {
      return strtolower(substr($file, strrpos($file, '.') + 1));
   }
   
   /**
    * Recursive directory searcher to locate any media and image files within any given path.
    *
    * @param - The path where to start your search.
    * @param - The files array.
    * @param - Used to keep track of the current folder when recursing.
    */    
   private function get_media_files($path, &$files, $folder = 0) 
   {
      // Only continue if this is a directory.
   	if(is_dir($path)) {
   	  
   	   // Open the directory.
   		if($contents = opendir($path)) {
   		 
   		   // Iterate through all the files in this directory.
   			while(($node = readdir($contents)) !== false) {
   			   
   			   // Make sure this is not the parent or current directory elements.
   				if($node!="." && $node!="..") {
   				  
   				   // If this node is a directory, then we will want to recurse.
   				   $directory = is_dir($path.'/'.$node);
   					if($directory) {
   					   
   					   // Get the index of this directory and recurse.
                     $index = (substr($node, $this->folderLength) - 1);
   					   $this->get_media_files($path.'/'.$node, $files, $index);
   					}
   					else if (!$directory){
   					 
   					   // If this is not a directory, then we need to add it to our files list.
   					   $extension = $this->get_file_ext($node);		
                     if( in_array($extension, $this->mediaTypes) ) {
   							$files[$folder]['media'][] = $path.'/'.$node;
   						}
   						else if( in_array($extension, $this->imageTypes) ) {
   							$files[$folder]['image'] = $path.'/'.$node;
   						}	
   					}
   				}
   			}
   		}
   	}
   }
   
   /**
    * Gets the mime type of a file.
    *
    * @return - The file to get the mime type of.
    */    
   private function getMimeType( $file )
   {
      $extension = $this->get_file_ext($file);
      switch( $extension )
      {
         case 'flv':
            return 'video/x-flv';
         case 'rtmp':
            return '';
         case 'mp4':
            return 'video/mp4';
         case 'm4v':
            return 'video/mp4';
         case 'mov':
            return 'video/quicktime';
         case '3g2':
            return '';
         case 'mp3':
            return 'audio/mpeg';
         case 'm4a':
            return 'audio/mp4';
         case 'aac':
            return '';
         case 'ogg':
            return '';
         case 'wav':
            return '';
         case 'aif':
            return '';
         case 'wma':
            return '';
         case 'jpg':
            return 'image/jpeg';
         case 'gif':
            return 'image/gif';
         case 'png':
            return 'image/png';
      }
   }
   
   /**
    * Returns a single track listing in an ASX XML format.
    *
    * @param - The file used for this track.
    * @param - The image associated with this track.
    */   
   private function asxGetTrack( $file, $image )
   {
      $output = '<entry>';
      $output .= "\n";
      $output .= '<title>' . basename($file) . '</title>';
      $output .= "\n";
      $output .= '<ref href="' . $file . '"/>';
                        
      if( $image ) {
         $output .= '<param name="image" value="' . $image . '"/>';
      }
                        
      $output .= "\n";
      $output .= '</entry>';
      $output .= "\n";
      return $output;  
   }
   
   /**
    * Returns the full playlist in ASX XML format.
    *
    * @param - The track contents.
    */  
   private function getASXXML( $content )
   {
      $output = '<asx version="3.0">';
      $output .= "\n";
      $output .= $content; 
      $output .= '</asx>'; 
      $output .= "\n";
      return $output;    
   }
   
   /**
    * Returns a single track listing in an RSS XML format.
    *
    * @param - The file used for this track.
    * @param - The image associated with this track.
    */   
   private function rssGetTrack( $file, $image )
   {
      $output = '<item>';
      $output .= "\n";
      $output .= '<title>' . basename($file) . '</title>';
      $output .= "\n";
      $output .= '<media:content url="' . $file . '" type="'. $this->getMimeType($file) .'"/>';
                        
      if( $image ) {
         $output .= '<media:thumbnail url="' . $image . '"/>';
      }
                        
      $output .= "\n";
      $output .= '</item>';
      $output .= "\n";
      return $output;  
   }
   
   /**
    * Returns the full playlist in RSS XML format.
    *
    * @param - The track contents.
    */   
   private function getRSSXML( $content )
   {
      $output = '<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss">';
      $output .= "\n";
      $output .= '<channel>';       
      $output .= "\n";
      $output .= $content;
      $output .= '</channel>'; 
      $output .= "\n";
      $output .= '</rss>';
      return $output;    
   }
   
   /**
    * Returns a single track listing in a playist XML format.
    *
    * @param - The file used for this track.
    * @param - The image associated with this track.
    */    
   private function playlistGetTrack( $file, $image )
   {
      $output = '<track>';
      $output .= "\n";
      $output .= '<title>' . basename($file) . '</title>';
      $output .= "\n";
      $output .= '<location>' . $file . '</location>';
                        
      if( $image ) {
         $output .= '<image>' . $image . '</image>';
      }
                        
      $output .= "\n";
      $output .= '</track>';
      $output .= "\n";
      return $output;  
   }
   
   /**
    * Returns the full playlist in Playlist XML format.
    *
    * @param - The track contents.
    */    
   private function getPlaylistXML($content)
   {
      $output = '<?xml version="1.0" encoding="UTF-8"?>';
      $output .= "\n";
      $output .= '<playlist version="1" xmlns="http://xspf.org/ns/0/"><trackList>'; 
      $output .= "\n";
      $output .= $content;
      $output .= '</trackList></playlist>';
      $output .= "\n";
      return $output;   
   }
}
?>