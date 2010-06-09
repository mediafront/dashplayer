/*
 * Dash Media Player: External Interface Gateway 
 * Copyright (c) 2008 TMT Digital LLC.
 *
 * Author:  Travis Tidwell | http://www.travistidwell.com
 *
 * Dependencies:
 *    jQuery Library
 *
 * This script is used as a connection interface gateway to control the player from an external source.
 * It is also used as a means for communication between multiple instances of the Dash Media Player
 * on the page.  This allows you to separate the Playlist and the actual
 * player on the page, but yet have them behave as a single player.  For more information on how you can
 * integrate this great feature on your website, visit http://www.tmtdigital.com/remoteplaylist
 *
 * License: GPL
 */

var dashReady = false;
var dashObjects = new Array();
var dashCallback = function( args ){};
var dashId = "dashplayer";

$(document).ready(function() {
   dashReady = true;  
});

function isDashReady() {
   return dashReady;
};

function dashDebug( arg ) {
   $('#dashdebug').append( arg + "<br/>" );
};

/** 
 * Gets the Dash Player Object given an ID
 *
 * @param - The ID of the player you would like to send this request too.
 */
function getDashObject( dashId ){
   var dashObj = null;       
                              
   // If there is a cached object, use it instead.
   if( dashObjects[dashId] ) {
      if( dashObjects[dashId].object ) {
         dashObj = dashObjects[dashId].object;
      }
   }
   
   if( !dashObj) {
      if( dashReady ) {
         if(navigator.appName.indexOf("Microsoft") != -1) {
            dashObj = window[dashId];
         }
         else {
            if(document[dashId].length !== undefined) {
               dashObj = document[dashId][1];
            }
            else {
               dashObj = document[dashId];
            }
         }
         if( dashObjects[dashId] ) {
            dashObjects[dashId].object = dashObj;
         }
      }
   }
   
   return dashObj;
};

/**
 * Adds a Dash Player object to the list of avialable
 * players.
 */
function dashAddObject( dashId ) {
   dashObjects[dashId] = {id:dashId, ready:false, object:null};
};

/**
 * Checks to see if all the players have registered.
 */
 
function isDashRegistered() {
   var registered = true;
   if( dashObjects ) {
      for( var dashId in dashObjects ) {
         if( dashObjects.hasOwnProperty( dashId ) ) {
            registered &= dashObjects[dashId].ready;
         }
      }
   }
   return registered;
};

/**
 * Initializes the dash player object.
 */
 
function dashInitialize( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {   
       try { 
          dashObj.initialize();
       } catch( error ) {
          dashDebug( error );
       }
   }
};

/** 
 * Starts the Dash Media Players
 */
function startDash()
{
   if( isDashRegistered() ) {
     for ( var dashId in dashObjects ) {
        if( dashObjects.hasOwnProperty( dashId ) ) {
           dashInitialize( dashId );
        }
      }
   }
};

/**
 * Registers a dash player object.
 */
function dashRegisterObject( dashId ) {
   if( !dashObjects.hasOwnProperty( dashId ) ) {
      dashAddObject( dashId );
   }
   dashObjects[dashId].ready = true;
   startDash();      
};

/** 
 * Spawns a player into a new window.
 *
 * @param - The ID of the player you would like to spawn.
 */
function dashSpawn( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) { 
       try { 
          dashObj.spawn();
       } catch( error ) {
          dashDebug( error );
       }          
       return true;
   }   
   return false;
};

/** 
 * Spawns a player into a new window.  For private use only.  External
 * components should not use this function, but use the dashSpawn 
 * function instead.  This is called from the Dash Media Player to 
 * spawn itself into a separate window.
 *
 * @param - The full path (including arguments) of the player to launch.
 * @param - The width of the spawned player.
 * @param - The height of the spawned player.
 */
function dashSpawnWindow( playerPath ) {
    try {
       window.open(playerPath);
    }
    catch( error ) {
       dashDebug( error );
    }
};

/** 
 * Loads a single node into the player.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The node ID of the node you would like for this player to load.
 */
function dashLoadNode( dashId, nodeId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {  
       try {  
          dashObj.loadNode( nodeId );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }   
   return false;
};

/** 
 * Loads a media file in the player.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The file that you would like for the player to load. 
 */
function dashLoad( dashId, file ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) { 
       try {   
          dashObj.loadMedia( file );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }  
   return false;
};

/** 
 * Plays a media file.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The file that you would like for the player to play.  
 *          This is not necessary if you use dashLoadNode or dashLoad before making this call.
 *          If you call this function with the file provided, then the player will load that file
 *          before actually playing it.
 */
function dashPlay( dashId, file ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {  
       try {  
          dashObj.playMedia( file );
       } catch( error ) {
          dashDebug( error );
       }         
       return true;
   }   
   return false;
};

/** 
 * Pauses the media file that is playing in the player.
 *
 * @param - The ID of the player you would like to send this request too.
 */
function dashPause( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {    
          dashObj.pauseMedia();
       } catch( error ) {
          dashDebug( error );
       }         
       return true;
   }
   return false;
};

/** 
 * Stops the media file that is playing in the player.
 *
 * @param - The ID of the player you would like to send this request too.
 */
function dashStop( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {    
          dashObj.stopMedia();
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Seeks the media file that is playing to the time specified.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The time that you would like to seek the track too.
 */
function dashSeek( dashId, seekTime ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {    
          dashObj.setSeek( seekTime );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the volume of the media being played.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The volume that you would like to set the media too.
 */
function dashVolume( dashId, vol ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       try {
          dashObj.setVolume( vol );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Gets the volume of the media being played.
 *
 * @param - The ID of the player you would like to send this request too.
 */
function dashGetVolume( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       try {
          return dashObj.getVolume();
       } catch( error ) {
          dashDebug( error );
       }         
   }
   return 0;
};

/** 
 * Sets the player into Full Screen mode..
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Boolean:  True - FullScreen, False - Normal
 */
function dashSetFullScreen( dashId, full ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {    
          dashObj.setFullScreen( full );
       } catch( error ) {
          dashDebug( error );
       }         
       return true;
   }
   return false;
};

/** 
 * Maximizes the player by getting rid of the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Boolean:  True - Maximize, False - Minimize
 * @param - Boolean:  Used to indicate if you want the transition to be tweened.
 */
function dashSetMaximize( dashId, max, tween ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {    
          dashObj.setMaximize( max, tween );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Maximizes the player by getting rid of the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Boolean:  True - Show Menu, False - Hide Menu
 * @param - Boolean:  Used to indicate if you want the transition to be tweened.
 */
function dashSetMenu( dashId, menu, tween ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {    
          dashObj.setMenu( menu, tween );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sees if the player has already loaded a node.
 *
 * @param - The ID of the player you would like to send this request too.
 *
 * @return - Boolean (True if is has loaded content, False otherwise)
 */
function dashIsNodeLoaded( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
      return (dashObj.isNodeLoaded());
   }
   return false;
};

/** 
 * Loads a playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The name of the playlist (view) you would like to load.
 */
function dashLoadPlaylist( dashId, playlist ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {      
          dashObj.loadPlaylist( playlist );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Loads the previous item in the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Indicate if you would like for the player to loop to the end of the list if it is already
 *          on the first item.
 * @param - Indicate if you would like for the playlist to play the file after it loads it.
 */
function dashLoadPrev( dashId, loop, playAfter ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {      
          dashObj.loadPrev( loop, playAfter );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Loads the next item in the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Indicate if you would like for the player to loop to the beginning of the list if it is already
 *          on the last item.
 * @param - Indicate if you would like for the playlist to play the file after it loads it.
 */
function dashLoadNext( dashId, loop, playAfter ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.loadNext( loop, playAfter );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Loads the previous page in the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Indicate if you would like for the player to loop to the last page if it is already
 *          on the first page.
 */
function dashPrevPage( dashId, loop ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {      
          dashObj.prevPage( loop );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Loads the next page in the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - Indicate if you would like for the player to loop to the beginning page if it is already
 *          on the last page.
 */
function dashNextPage( dashId, loop ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.nextPage( loop );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the filter argument for the playlist currently loaded.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The argument that you would like to pass to your playlist to filter the content.
 * @param - The index of the argument.
 */
function dashSetFilter( dashId, argument, index ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.setFilter( argument, index );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the playlist of the media player.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The message object that you would like to use to provide to the playlist.
 */
function dashSetPlaylist( dashId, message ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.setPlaylist( message );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the vote of the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The message object that you would like to use to provide to the playlist.
 */
function dashSetPlaylistVote( dashId, nodeId, voteTag, voteValue ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.setPlaylistVote( nodeId, {tag:voteTag, value:voteValue} );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the user vote of the playlist.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The message object that you would like to use to provide to the playlist.
 */
function dashSetPlaylistUserVote( dashId, nodeId, voteTag, voteValue ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.setPlaylistUserVote( nodeId, {tag:voteTag, value:voteValue} );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the vote of the node.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The message object that you would like to use to provide to the playlist.
 */
function dashSetVote( dashId, voteTag, voteValue ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.setVote( {tag:voteTag, value:voteValue} );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Sets the user vote of the node.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The message object that you would like to use to provide to the playlist.
 */
function dashSetUserVote( dashId, voteTag, voteValue ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {
       try {         
          dashObj.setUserVote( {tag:voteTag, value:voteValue} );
       } catch( error ) {
          dashDebug( error );
       }        
       return true;
   }
   return false;
};

/** 
 * Resets the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 */
function dashResetControls( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.resetControls();
       return true;
   }
   return false;
};

/** 
 * Enables/Disables the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - true - Enable the controls :  false - Disable the controls.
 */
function dashEnableControls( dashId, enable ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.enableControls(enable);
       return true;
   }
   return false;
};

/** 
 * Sets the state of the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The state you would like to set this control bar too.
 *             "play"  - Play State
 *             "pause" - Pause State
 */
function dashSetControlState( dashId, state ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.setControlState(state);
       return true;
   }
   return false;
};

/** 
 * Sets the total time print out of the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The time that you would like to set on the controls.
 */
function dashSetControlTime( dashId, time ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.setControlTime(time);
       return true;
   }
   return false;
};

/** 
 * Sets the volume of the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The volume that you would like to set on the controls.
 */
function dashSetControlVolume( dashId, volume ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.setControlVolume(volume);
       return true;
   }
   return false;
};

/** 
 * Sets the progress indication of the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The progress that you would like to set on the controls.
 */
function dashSetControlProgress( dashId, progress ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.setControlProgress(progress);
       return true;
   }
   return false;
};

/** 
 * Sets the seek indication of the controls.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The seek that you would like to set on the controls.
 */
function dashSetControlSeek( dashId, seek ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.setControlSeek(seek);
       return true;
   }
   return false;
};

/** 
 * Updates the controls given the play time and total time..
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The playhead time.
 * @param - The total time of the media being played.
 */
function dashControlUpdate( dashId, playTime, totalTime ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.controlUpdate(playTime, totalTime);
       return true;
   }
   return false;
};

/** 
 * Dynamically sets the Dash Media Player skin..
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The skin you would like to switch to.
 */
function dashSetSkin( dashId, skin ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.setSkin( skin );
       return true;
   }
   return false;
};

/** 
 * Calls a Dash Media Player service routine.  The player must have the external service
 * flag set to true in order for this to work properly.
 *
 * @param - The ID of the player you would like to send this request too.
 * @param - The command that you would like to send to the service.
 * @param - The callback that will get called with the response.
 */

function dashServiceCall() {
   var dashId = arguments[0];
   arguments.shift();
   var command = arguments[0];
   arguments.shift();
   dashCallback = arguments[0];
   arguments.shift();
   
   var dashObj = getDashObject( dashId );
   if( dashObj ) {         
       dashObj.serviceCall( command, arguments );
       return true;
   }
   return false;
};

/** 
 * Return from the service call.
 *
 * @param - An array of the arguments that gets passed back.
 */

function dashServiceReturn( args ) {
   dashCallback( args );   
};

/** 
 * YouTube wrapper functions.
 */
function onYouTubePlayerReady( playerId ) {
   dashId = playerId;
   var dashObj = getDashObject( playerId );
   if( dashObj ) {
      try {
         dashObj.addEventListener("onStateChange", "youTubeOnStateChange");
         dashObj.addEventListener( "onError", "youTubeOnError" ); 
         dashObj.onYouTubeReady();
      }
      catch( error ) {
         dashDebug( error );
      }
   }
};

function youTubeOnStateChange( newState ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.onYouTubeStateChange( newState );
   }     
};

function youTubeOnError( error ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.onYouTubeError( error );
   }     
};

function youTubeLoad( dashId, youTubeId, startSeconds ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.loadVideoById( youTubeId, startSeconds );
   }
};

function youTubeCue( dashId, youTubeId, startSeconds ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.cueVideoById( youTubeId, startSeconds );
   }
};

function youTubeDestroy( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.destroy();
   }
};

function youTubeClear( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.clearVideo();
   }
};

function youTubeSetSize( dashId, _width, _height ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.setSize( _width, _height );
   }
};

function youTubePlay( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.playVideo();
   }
};

function youTubePause( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.pauseVideo();
   }
};

function youTubeStop( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.stopVideo();
   }
};

function youTubeSeek( dashId, seconds, allowSeekAhead ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.seekTo( seconds, allowSeekAhead );
   }
};

function youTubeGetBytesLoaded( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getVideoBytesLoaded();
   }
   return 0;
};

function youTubeGetBytesTotal( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getVideoBytesTotal();
   }
   return 0;
};

function youTubeGetCurrentTime( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getCurrentTime();
   }
   return 0;
};

function youTubeGetDuration( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getDuration();
   }
   return 0;
};

function youTubeSetVolume( dashId, newVolume ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
       dashObj.setVolume( newVolume );
   }
};

function youTubeGetVolume( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getVolume();
   }
   return 0;
};

function youTubeGetEmbedCode( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getEmbedCode();
   }
   return "";
};

function youTubeGetVideoUrl( dashId ) {
   var dashObj = getDashObject( dashId );
   if( dashObj ) {    
      return dashObj.getVideoUrl();
   }
   return "";
};