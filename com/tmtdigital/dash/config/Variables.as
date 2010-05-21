/**
 * Variables.as - See class description for information.
 *
 * Author - Travis Tidwell ( travist@tmtdigital.com )
 * License - General Public License ( GPL version 3 )
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/
 **/
package com.tmtdigital.dash.config
{
	/**
	 * The variables class is used to keep track of all parameters that this
	 * player accepts from outside configurations.
	 */
   public class Variables extends Object
   {
      public var arg:Object = new Object();
      public var autohide:Boolean = true;
      public var autoload:Boolean = true;
      public var autonext:Boolean = true;
      public var autostart:Boolean = false;
      public var bufferlength:uint = 5;		
      public var colors:Object = new Object();
      public var connect:String = "";
      public var controlbaronly:Boolean = false;
      public var controlbarskin:String = "controlbar";
      public var disableembed:Boolean = false;		
      public var disablemenu:Boolean = false;
      public var disableplaylist:Boolean = false;
      public var embedheight:Number = 267;
      public var embedwidth:Number = 320;
      public var externalservice:Boolean = false;
      public var file:String = "";
      public var flashonly:Boolean = false;		
      public var image:String = null;
      public var intro:String = "";		
      //public var link:String = "http://www.tmtdigital.com/project/dash_player";
      public var link:String = "";
      public var linkarg:Object = new Object();
      public var linkalltext:String = "all";
      public var linkindex:Object = new Object();
      public var linktext:Object = new Object();
      public var linksvertical:Boolean = false;
      //public var logo:String = "dashLogo.png";
      public var logo:String = "";
      public var logopos:String = "BL";
      public var logowidth:Number = 0;
      public var logox:Number = 2;
      public var logoy:Number = 2;
      public var loop:Boolean = false;
      public var magnify:Boolean = false;		
      public var node:Number = 0;
      public var pagelink:Boolean = false;
      public var pagelinkarg:String = "?q=node/";
      public var pagelimit:Number = 10;
      public var playlist:String = "";
      public var playlistlogo:String = "";
      public var playlistsize:uint = 0;
      public var playlistonly:Boolean = false;
      public var playlistindex:Number = 0;
      public var playlistpage:Number = 0;
      public var playlistskin:String = "playlist";
      public var postreel:String = "";		
      public var scalevideo:Boolean = true;
      public var scrollspeed:Number = 15;
      public var seekvertical:Boolean = false;
      public var showcontrols:Boolean = true;
      public var showdash:Boolean = false;
      public var showinfo:Boolean = true;
      public var showplaylist:Boolean = true;
      public var shuffle:Boolean = false;		
      public var skin:String = "default";
      public var streamer:String = "";		
      public var taggingenabled:Boolean = false;
      public var taglinkcolor:uint = 0x6666FF;
      public var tagplaylist:String = '';
      public var teaserplay:Boolean = false;
      public var teaserselect:Boolean = true;
      public var termlinks:Boolean = true;
      public var termspacing:Number = 5;
      public var theme:String = "default";
      public var tweentime:Number = 10;
      public var vertical:Boolean = true;
      public var viewsenabled:Boolean = true;
      public var volume:uint = 80;
      public var volumevertical:Boolean = false;
      public var votingenabled:Boolean = true;

      /* Undocumented */
      public var api:uint = 3;
		public var captions:Boolean = false;
      public var type:String = "";
      public var commercial:String = "";
      public var prereel:String = "";
      public var spectrum:String = "";  
      public var voter:String = "";
      public var service:String = "";
      public var playerparams:String = "";
      public var preloader:String = "default";
      public var cacheload:Boolean = true;
      public var menu:String = "";  
      public var spinner:String = "";
      public var delay:Number = 0;
      public var cache:Boolean = true;
      public var volumeinterval:Number = 10;
      public var diameter:Number = 392;
      public var amplitude:Number = 25;
      public var teaserspace:Number = 0;
      public var id:String = "";
      public var trackuser:Boolean = false;
      public var drupalversion:Number = 0;
      public var autoscroll:Boolean = true;
      public var incrementtime:Number = 5;
      public var subplypath:String = "http://content.plymedia.com/players/default/plyviewer";
   }
}