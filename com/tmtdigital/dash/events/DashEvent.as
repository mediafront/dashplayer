/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Class containing all Dash Events in the Dash Player.
 *
 **/

package com.tmtdigital.dash.events
{
   import flash.events.*;

   public class DashEvent extends Event
   {
      public static const TEASER_CLICK:String = "teaserClick";
		public static const LINK_CLICK:String = "linkClick";
      public static const NODE_LOADED:String = "nodeLoaded";
      public static const PREV:String = "previous";
      public static const NEXT:String = "next";
      public static const STOP:String = "stop";
      public static const MEDIA_CONNECTED:String = "mediaConnected";		
      public static const MEDIA_LOADING:String = "mediaLoading";
      public static const MEDIA_BUFFERING:String = "mediaBuffering";
      public static const MEDIA_PAUSED:String = "mediaPaused";
      public static const MEDIA_PLAYING:String = "mediaPlaying";
      public static const MEDIA_STOPPED:String = "mediaStopped";
      public static const MEDIA_PROGRESS:String = "mediaProgress";
      public static const MEDIA_UPDATE:String = "mediaUpdate";
      public static const MEDIA_READY:String = "mediaReady";
      public static const MEDIA_COMPLETE:String = "mediaComplete";
      public static const MEDIA_METADATA:String = "mediaMetaData";
      public static const VOTE_SET:String = "voteSet";
      public static const VOTE_GET:String = "voteGet";
      public static const VOTE_DELETE:String = "voteDelete";
      public static const PROCESSING:String = "processing";
      public static const LOAD_PAGE:String = "loadPage";	
      public static const LOAD_INDEX:String = "loadIndex";				

      /**
       *  Constructor for the DashEvent object.
       *
       *  @param - The type of event that you would like to use (see above).
       *  @param - The argument object that will be passed with this event.
       */
      public function DashEvent( type:String, a:Object = null )
      {
         super( type, true );
         args = a;
      }

      override public function toString():String
      {
         return formatToString( "DashEvent", "type", "eventPhase" );
      }

      override public function clone():Event
      {
         return new DashEvent( type, args );
      }

      public var args:Object;
   }
}