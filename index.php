<html>
   <head><title>Dash Media Player PHP Demo</title></head>
   <body>
      <div style="text-align:center;">
         <h2>Dash Media Player PHP Demo</h2><br/>
         <?php
         include("dash.php");
         $params['width'] = 652;
         $params['height'] = 432;
         print dashplayer_get_player($params);
         
         /*
          // OR YOU COULD USE THE FOLLOWING...
          include("DashPlayer.php");
          $params['width'] = 652;
          $params['height'] = 432;          
          $player = new DashPlayer($params);
          $player->show();
         */
         
         ?>
      </div>
   </body>
</html>