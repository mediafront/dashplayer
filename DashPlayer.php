<?php
require_once("DashUtils.php");

/**
 * The Dash Media Player Class
 *
 * License:    GPL
 * Author:     Travis Tidwell    (www.travistidwell.com)
 * Copyright:  TMT Digital 2008  (www.tmtdigital.com)
 *
 * This class is used to construct or show the player on your page.  It does this by constructing
 * the DashPlayer object with a set of parameters in acociative array form.  See constructor comments for more information.
 *
 */
 
class DashPlayer
{
   private $params;   
   
   /**
    * Constructor.
    *
    * @param - An associative array of parameters for this player to use when showing.  These can be as follows.
    *
    *    width    - The width of the player.
    *    height   - The height of the player.
    *    id       - The HTML ID of the player.
    *    schema   - The XML schema of the playlist to generate (XML, RSS, or ASX).
    *    file     - The file to play.  If none is provided, then this will play the generated playlist.
    *    playlist - The playlist to play.
    *
    *    All other parameters are the FlashVars used to govern the player.  These can be found by going to http://www.tmtdigital.com/flashvars .
    *
    *    Example 1:  To show a media player that will play the file http://www.mysite.com/videos/video.flv, you would use the following code...
    *
    *       <?php
    *          $params['file'] = 'http://www.mysite.com/videos/video.flv';
    *          $player = new DashPlayer($params);
    *          $player->show();
    *       ?>
    *
    *    Example 2:  To show the default playlist in the playlists folder...
    *
    *       <?php
    *          $player = new DashPlayer();
    *          $player->show();
    *       ?>
    *
    */ 
   public function DashPlayer( $_params = array() )
   {
      $this->params = $_params;      
   }   
   
   /**
    * Shows the media player on your PHP page.
    */ 
   public function show()
   {
      print $this->getPlayer();      
   }
   
   /**
    * Returns the player object HTML code.
    *
    * @return - The Dash Media Player HTML code.
    */ 

   public function getPlayer()
   {
      $flashvars = '';
      $width = 652;
      $height = 432;
      $player = 'dashPlayer.swf';
      $playlist = 'default';
      $id = 'dashplayer';
      $schema = 'xml';
      $file = '';
         
      foreach($this->params as $param => $value) {
         $param = strtolower($param);
      
         if( $param != 'file' ) 
         {
            switch( $param )
            {
               case 'player':
                  $player = $value;
                  break;
               case 'width':
                  $width = $value;
                  break;
               case 'height':
                  $height = $value;
                  break;
               case 'id':
                  $flashvars .= $param . '=' . $value . '&';
                  $id = $value;
                  break;
               case 'schema':
                  $schema = $value;
                  break;
               case 'file':
                  $file = 'file=' . $value;
                  break;
               case 'playlist':
                  $playlist = $value;
                  break;               
               default:
                  $flashvars .= $param . '=' . $value . '&';
                  break;
            }
         }
      }
   
      $url = dash_base_url();
      $path = getcwd();
   
      if( !$file )
      {
         if( file_exists( $path . '/cache/' . $playlist . '.xml' ) ) {
            $file = 'file=' . $url . '/cache/' . $playlist . '.xml';
         }
         else {
            $file = 'file=' . $url . '/getplaylist.php?playlist=' . $playlist;
         }
      }
   
      $output = ''; 
       
      if( $url )
      {
         $flashvars = $file . '&votingenabled=false&viewsenabled=false&' . rtrim($flashvars, '&');   
         $loader_path = $url . '/' . $player;    
         $output .= '<object id="'. $id .'" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="'.$width.'" height="'.$height.'" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab">' . "\n";
         $output .= '<param name="movie" value="'. $loader_path .'" />' . "\n";
         $output .= '<param name="wmode" value="transparent" />' . "\n";
         $output .= '<param name="allowfullscreen" value="true" />' . "\n";
         $output .= '<param name="FlashVars" value="'.$flashvars.'" />' . "\n";
         $output .= '<param name="quality" value="high" />' . "\n";
         $output .= '<embed name="' . $id .'" allowScriptAccess="always" src="'. $loader_path .'" width="'.$width.'" height="'.$height.'" border="0" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" wmode="transparent" allowfullscreen="true" quality="high" flashvars="'.$flashvars.'" /></object>' . "\n";
      }
      
      return $output;      
   }   
}
?>