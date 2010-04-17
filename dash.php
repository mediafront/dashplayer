<?php
include('DashPlayer.php');
/**
 * Global API function to quickly show the Dash Media Player given a set of parameters.
 *
 * For more information, go to http://www.tmtdigital.com/node/399
 *
 * @param - The parameters used to construct the player.
 *
 * @return - The object code used to display the Dash Media Player in your page.
 */
function dashplayer_get_player( $params = array() ) 
{
   $player = new DashPlayer( $params );
   return $player->getPlayer();
}
?>