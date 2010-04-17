/**
 * Params.as - See class description for information.
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
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.config.Variables;
   
   import flash.events.*;
   import flash.display.*;
   import flash.net.*;

   /**
    * The Params class keeps track of all parameters used in the player.  
    * It allows for passing parameters using a config file, FlashVars, 
    * or through the use of Component initialization.
    */
   public class Params
   {
      /**
       * Loads the parameters that this player will use.  It does this by searching
       * for a player configuration XML file in the config directory.
       *
       * @param - The loader information for this movie using this parameters class.
       * @param - The callback function when the parameters have finished loading.
       */
      public static function loadParams( _loaderInfo:LoaderInfo, _onLoaded:Function )
      {
         loaderInfo = _loaderInfo;
         onLoaded = _onLoaded;

         // Get the configuration to use for this player.
         if (loaderInfo.parameters.hasOwnProperty("config")) {
            config = loaderInfo.parameters.config;
         }

         // They can use "internal" as the configuration if they do not wish to 
         // specify the parameters in an external XML file.
         if (config != "internal") {
            flashVars = new Variables();
            
            // Get the configuration XML path.
            loaderURL = LoaderInfo(loaderInfo).url;
            playerPath = loaderURL + "?config=" + config;
            var configURL:String = getRootPath();
            var xmlURL:String = "";
            xmlURL += configURL + "/";
            xmlURL+="config/"+config+".xml";
            
            // Load the XML configuration file.
            Utils.loadXML( xmlURL, onConfigLoad, onConfigLoadError );
         } else {
            loadConfig(null);
         }
      }

      /**
       * Gets the root path of the player.
       *
       * @return String - A string of the root path for this player.
       */
      public static function getRootPath():String
      {
         if( !loaderPath ) {
            var paths:Array = new Array();
            var file:String = loaderURL;
            if( file.search( /\?/ ) >= 0 ) {
               paths = file.split(/\?/);
               file = paths[0];
            }
            paths = file.split(/[\\\/]/);;
            paths.pop();
            loaderPath = paths.join("/");
         }
         
         return loaderPath;
      }

      /**
       * Gets the base URL of the player.
       *
       * @return String - A string of the base URL for the player.
       */
      public static function getBaseURL():String
      {
         var url:RegExp=/^(http[s]?\:[\\\/][\\\/])([^\\\/\?]+)/;
         return url.exec(loaderURL);
      }

      /**
       * Loads the configuration.
       *
       * @param settings - An XML representation of the settings.
       * @param initialValues - Boolean to tell this load function if this is the first pass at loading
       * the variables.
       */
      public static function loadConfig( settings:XML, initialValues:Boolean = true )
      {
         if (settings) {
            if (settings.hasOwnProperty("gateway") && settings.gateway.children().toString().length) {
               gateway=settings.gateway;
            }

            if (settings.hasOwnProperty("apiKey") && settings.apiKey.children().toString().length) {
               apiKey=settings.apiKey;
            }

            if (settings.hasOwnProperty("license") && settings.license.children().toString().length) {
               license=settings.license;
            }

            if (! baseURL) {
               if (settings.hasOwnProperty("baseURL") && settings.baseURL.children().toString().length) {
                  baseURL=settings.baseURL;
               } else {
                  baseURL=getBaseURL();
               }
            }

            if (settings.hasOwnProperty("flashvars")) {
               loadFlashVars( settings.flashvars, initialValues );
            }
         }

         // Load the Flash variables. 
         loadFlashVars( LoaderInfo(loaderInfo).parameters, initialValues );
         
         // Load the embed variables.
         loadEmbedVars();

         // Trigger our "onLoaded" callback.
         if ( initialValues ) {
            onLoaded();
         }
      }

      /**
       * See if the playlist should be shown or not.
       *
       * @return Boolean - Indicate if the playlist should be shown ( true ) or not ( false ).
       */
      public static function get showPlaylist():Boolean
      {
         return (flashVars.showplaylist && !flashVars.disableplaylist);
      }

      /**
       * Actually loads the flashvars given a set of variables.
       *
       * @param - The set of variables to load into our data model.
       */
      public static function loadFlashVars( _variables:*, initialValues:Boolean = true )
      {
         var paramIndex:int=0;

         if (_variables is XMLList) {
            for each (var xmlVar in _variables.elements()) {
               setParameter( xmlVar.localName(), xmlVar.children().toString(), initialValues );
            }
         } else {
            for (var variable in _variables) {
               setParameter( variable, _variables[variable], initialValues );
            }
         }
      }

      // Called when an error occured when the configuration file was loading.  Here we will just 
      // go ahead and load the flash vars, and then dispatch an event to the base that we are finished.
      private static function onConfigLoadError(event:Object)
      {
         config="internal";
         loadConfig(null);
      }

      // Called when the configuration file has finished loading.  We will simply override any of our
      // defaults with the values provided in the configuration file.
      private static function onConfigLoad(event:Event)
      {
         var settings:XML=null;

         if (event&&event.target) {
            settings=new XML(event.target.data);
         }

         loadConfig(settings);
      }

      /**
       * Sets a single parameter given a param string and a value for that parameter.
       *
       * @param param - The parameter to set.
       * @param value - The value of the parameter to set.
       * @param initialValues - If this is a first pass at setting the parameters.
       */
      private static function setParameter( param:String, value:String, initialValues:Boolean )
      {
         param=param.toLowerCase();
         
         if( initialValues ) {
            playerPath += "&" + param + "=" + value;
         }
         
         if (param.indexOf("color")===0) {
            flashVars.colors[param]=Number(value);
         } else if ( param.indexOf("arg") === 0 ) {
            parseArrayArg( "arg", param, value );
         } else if ( param.indexOf("linkarg") === 0 ) {
            parseArrayArg("linkarg", param, value );
         } else if ( param.indexOf("linktext") === 0 ) {
            parseArrayArg( "linktext", param, value );
         } else if ( param.indexOf("linkindex") == 0 ) {
            parseArrayArg( "linkindex", param, value );
         } else if ( flashVars.hasOwnProperty(param) ) {
            if (flashVars[param] is Boolean) {
               flashVars[param]=parseBoolean(value);
            } else {
               flashVars[param]=value;
            }
         }
      }

      /**
       * Parses an argument that is structured to be in array form.  Example, "color", "color1", "color2", etc.
       *
       * @param variable - The name of the array that will be storing these values.
       * @param param - The actual parameter name.
       * @param value - The value of the parameter.
       */
      private static function parseArrayArg( variable:String, param:String, value:String )
      {
         var index:Number=Number(param.substr(variable.length))-1;
         if( index >= 0 ) {
            flashVars[variable][index] = value;
         }
      }

      /**
       * Pushes all of the valid embedded variables into the embedVars array to be used
       * when the user clicks to embed this player in their site.
       */
      private static function loadEmbedVars()
      {
         embedVars = new Array();

         if (config!="dashconfig") {
            embedVars.push( "config=" + config );
         }

         if (flashVars.link) {
            embedVars.push( "link=" + flashVars.link );
         }

         if (flashVars.logowidth) {
            embedVars.push( "logowidth=" + flashVars.logowidth );
         }

         if (flashVars.logoy) {
            embedVars.push( "logoy=" + flashVars.logoy );
         }

         if (flashVars.logox) {
            embedVars.push( "logox=" + flashVars.logox );
         }

         if (flashVars.logopos) {
            embedVars.push( "logopos=" + flashVars.logopos );
         }

         if (flashVars.logo) {
            embedVars.push( "logo=" + flashVars.logo );
         }

         if (flashVars.theme) {
            embedVars.push( "theme=" + flashVars.theme );
         }
      }

      /**
       * Parses a string as a boolean variable.
       *
       * @param flashVar - The flashvar string to be parsed.
       * @return Boolean - If the value of this variable is true or false.
       */
      private static function parseBoolean( flashVar:String ):Boolean
      {
         if (flashVar.toLowerCase()==="false") {
            return false;
         } else if ( flashVar === "0" ) {
            return false;
         } else if ( !flashVar ) {
            return false;
         }

         return true;
      }

      /**
       * The current configuration file to use.
       */
      public static var config:String="dashconfig";
      
      /**
       * The gateway to use for server communication.
       */      
      public static var gateway:String="";
      
      /**
       * The API key to use for the gateway.
       */      
      public static var apiKey:String="";
      
      /**
       * The baseURL of the player.
       */      
      public static var baseURL:String="";
      
      /**
       * The embed variables used to populate the embed functionality.
       */         
      public static var embedVars:Array;
      
      /**
       * The path of the player.
       */         
      public static var playerPath:String;
      
      /**
       * The flash variables used to configure player functionality.
       */         
      public static var flashVars:Variables;
      
      /**
       * The loader information URL path.
       */         
      public static var loaderURL:String;
      
      // private variables.
      private static var loaderPath:String="";
      private static var loaderInfo:LoaderInfo;
      private static var onLoaded:Function;
      public static var license:String="";		
   }
}