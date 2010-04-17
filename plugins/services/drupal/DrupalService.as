/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The DrupalService class is the interface between Drupal
 * and the Dash Player.  It is used to send and receive messages from the 
 * Drupal CMS.
 *
 **/

package com.tmtdigital.dash.net
{
   import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.config.Params;
   import com.tmtdigital.dash.net.Service;

   import flash.net.*;
   import flash.events.*;
   import flash.display.*;
   import flash.utils.*;
   import com.hurlant.crypto.hash.SHA256;
   import com.hurlant.crypto.hash.HMAC;
   import com.hurlant.util.Hex;

   public class DrupalService extends NetConnection
   {
      public function DrupalService()
      {
         addEventListener(StatusEvent.STATUS, onStatus);
         addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
         addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
      }

      public function connectToGateway( _onReady:Function )
      {
         onReady = _onReady;
         if (Params.gateway.length > 0) {
            objectEncoding = flash.net.ObjectEncoding.AMF3;
            setupCommands();				

            try {
               connect( Params.gateway );
            } catch (error:Error) {
               trace("Connection Failed: " + error);
            }

            Service.call( Service.SYSTEM_CONNECT, onConnect, onConnectFailed, new Array() );
         }
      }

      private function setupCommands()
      {
         var hasKey:Boolean = false;
         if( Params.apiKey ) {
            hasKey = (Params.apiKey.length > 0);
         }			
			
         commands = new Object();
         commands[Service.SYSTEM_CONNECT] = {command:"system.connect", useKey:false};
         commands[Service.SYSTEM_MAIL] = {command:"system.mail", useKey:hasKey};
         commands[Service.NODE_LOAD] = {command:"node.load", useKey:false};			
         commands[Service.GET_VERSION] = {command:"dashplayer.getDrupalVersion", useKey:false};			
         commands[Service.GET_VIEW] = {command:"dashplayer.getView", useKey:false};			
         commands[Service.GET_VOTE] = {command:"vote.getVote", useKey:false};			
         commands[Service.SET_VOTE] = {command:"vote.setVote", useKey:hasKey};			
         commands[Service.GET_USER_VOTE] = {command:"vote.getUserVote", useKey:false};			
         commands[Service.DELETE_VOTE] = {command:"vote.deleteVote", useKey:hasKey};			
         commands[Service.ADD_TAG] = {command:"tag.addTag", useKey:hasKey};			
         commands[Service.INCREMENT_NODE_COUNTER] = {command:"dashplayer.incrementNodeCounter", useKey:hasKey};
         commands[Service.SET_FAVORITE] = {command:"favorites.setFavorite", useKey:hasKey};			
         commands[Service.DELETE_FAVORITE] = {command:"favorites.deleteFavorite", useKey:hasKey};			
         commands[Service.IS_FAVORITE] = {command:"favorites.isFavorite", useKey:false};			
         commands[Service.USER_LOGIN] = {command:"user.login", useKey:hasKey};			
         commands[Service.USER_LOGOUT] = {command:"user.logout", useKey:hasKey};			
         commands[Service.AD_CLICK] = {command:"dashplayer.adClick", useKey:hasKey};			
         commands[Service.GET_AD] = {command:"dashplayer.getAd", useKey:false}; 
         commands[Service.SET_USER_STATUS] = {command:"dashplayer.setUserStatus", useKey:hasKey}; 
      }

      private function onStatus(e:StatusEvent):void
      {
         if (e.level == "error") {
            trace("NetConnection.send() failed: " + e);
         }
      }

      private function securityErrorHandler(e:SecurityErrorEvent):void
      {
         trace("Security Error: " + e);
      }

      private function netStatusHandler(e:NetStatusEvent):void
      {
         if (e.info.level == "error") {
            trace("NetConnection Failed: " + e);
         }
      }

      public function login( username:String, password:String, _onLogin:Function, _onLoginFailed:Function )
      {
         username = username.replace(/[\t\n\r\f]/,'');
         password = password.replace(/[\t\n\r\f]/,'');

         if (username.length && password.length) {
            onLoginCallback = _onLogin;
            Service.call( Service.USER_LOGIN, onLogin, _onLoginFailed, username, password );
         } else {
            _onLoginFailed( {description:"You must provide a username and password to login."} );
         }
      }

      public function logout( _onLogout:Function, _onLogoutFailed:Function )
      {
         if (user && user.userid) {
            onLoginCallback = _onLogout;
            Service.call( Service.USER_LOGOUT, onLogin, _onLogoutFailed );
         } else {
            _onLogoutFailed( {description:"You must be logged in to logout."} );
         }
      }

      public function serviceCall( message:Object ) : Boolean
      {
         if( ( message.command == Service.SYSTEM_CONNECT) || sessionId )
         {
            if (message.onFailed == null) {
               message.onFailed = onFault;
            }

            var responder:Responder = new Responder(message.onSuccess,message.onFailed);
            setupArgs( message );

            try {
               switch ( message.args.length ) {
                  case 0 :
                     call( message.command, responder );
                     break;

                  case 1 :
                     call( message.command, responder, message.args[0] );
                     break;

                  case 2 :
                     call( message.command, responder, message.args[0], message.args[1] );
                     break;

                  case 3 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2] );
                     break;

                  case 4 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3] );
                     break;

                  case 5 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4] );
                     break;

                  case 6 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5] );
                     break;

                  case 7 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6] );
                     break;

                  case 8 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6], message.args[7] );
                     break;

                  case 9 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6], message.args[7], message.args[8] );
                     break;

                  case 10 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6], message.args[7], message.args[8], message.args[9] );
                     break;

                  case 11 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6], message.args[7], message.args[8], message.args[9], message.args[10] );
                     break;

                  case 12 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6], message.args[7], message.args[8], message.args[9], message.args[10], message.args[11] );
                     break;

                  case 13 :
                     call( message.command, responder, message.args[0], message.args[1], message.args[2], message.args[3], message.args[4], message.args[5], message.args[6], message.args[7], message.args[8], message.args[9], message.args[10], message.args[11], message.args[12] );
                     break;
               }
               
               return true;
               
            } catch (error:Error) {
               trace( error );
            }
         }
         
			return false;
      }

      private function setupArgs( message:Object )
      {
         var command:Object = getCommand( message.command );
         message.command = command.command;
         message.args.unshift( sessionId );
			
         var useKey:Boolean = (message.useKey is Boolean) ? message.useKey : command.useKey;
			
         if ( useKey ) {
            if (Params.flashVars.api > 1) {
               var baseURL:String = Params.baseURL.replace(/^(http[s]?\:[\\\/][\\\/])/,'');
               var timestamp:String = getTimeStamp();
               var nonce:String = getNonce();
               var hash:String = computeHMAC(timestamp,baseURL,nonce,message.command,Params.apiKey);
               message.args.unshift( nonce );
               message.args.unshift( timestamp );
               message.args.unshift( baseURL );
               message.args.unshift( hash );
            } else {
               message.args.unshift( Params.apiKey );
            }
         }

         if ( version == 6 && (message.command == Service.NODE_LOAD) ) {
            return "node.get";
         }
      }

      private function getCommand( _command:String ) : Object
      {
         var drupalCommand:Object = commands[_command];
         if( drupalCommand ) {
            return drupalCommand;
         }
			
         return {command:_command, useKey:false};
      }

      private function onLogin( result:* ):void
      {
         if (result is Boolean) {
            user = new Object();
         } else {
            sessionId = result.sessid;
            user = result.user;
         }

         onLoginCallback();
      }

      private function onConnect(result:Object):void
      {
         if( result ) {
            sessionId = result.sessid;
            user = result.user;
         }

         if( Params.flashVars.drupalversion > 0 ) {
            onVersion(Params.flashVars.drupalversion);
         } else {
            Service.call( Service.GET_VERSION, onVersion, onConnectFailed );
         }
      }

      private function onVersion( _version:Number ):void
      {
         version = _version;
         onReady();
      }

      private function onConnectFailed(error:Object):void
      {
         trace("Drupal connection failed");
      }

      private function onFault(error:Object):void
      {
         for each (var item in error) {
            trace(item);
         }
      }

      private function computeHMAC(timestamp:String, domain:String, nonce:String, method:String, apiKey:String):String
      {
         var input:String = timestamp + ";" + domain + ";" + nonce + ";" + method;
         var hmac:HMAC = new HMAC( new SHA256() );
         var kdata:ByteArray = Hex.toArray(Hex.fromString(apiKey));
         var data:ByteArray = Hex.toArray(Hex.fromString(input));
         var currentResult:ByteArray = hmac.compute(kdata,data);
         return Hex.fromArray(currentResult);
      }

      private function getNonce():String
      {
         var allowable_characters:String = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
         var len:int = allowable_characters.length - 1;
         var pass:String = '';

         for (var i:int = 0; i < 10; i++) {
            pass += allowable_characters.charAt(Utils.rand(len));
         }

         return pass;
      }

      private function getTimeStamp():String
      {
         var now:Date = new Date();
         var nowTime:Number=Math.floor((now.getTime() / 1000));
         return int(nowTime).toString();
      }

      public var user:Object;
      public var sessionId:String="";
      private var commands:Object;
      private var onLoginCallback:Function;
      private var onReady:Function;
      private var version:Number;		
   }
}