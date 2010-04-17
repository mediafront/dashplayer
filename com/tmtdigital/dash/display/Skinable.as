/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The base class for any skinable element in the Dash Player.
 *
 **/

package com.tmtdigital.dash.display
{
	import com.tmtdigital.dash.DashPlayer;
	import com.tmtdigital.dash.utils.Resizer;
   import flash.display.*;
   import flash.events.*;   
   import flash.net.*;   

   public class Skinable extends Sprite
   {
      /**
       * This class can either use an existing MovieClip for the skin, or can load a new one
       * using an external URL.
       *
       * @param - The original movie clip skin.  If none, then just pass null.
       * @param - The path to the external MovieClip to load into this skin.
       * @param - A simple callback function to call when the skin has been loaded.
       */
      public function Skinable( _skin:MovieClip, _skinPath:String = null, _onLoaded:Function = null )
      {
         super();
         
         // Set the rootSkin to the DashPlayer skin.
			rootSkin = DashPlayer.skin;
			onSkinLoaded = _onLoaded;
			
			// If they provide a path to an external skin, then try to load it.
			if( _skinPath ) {
			   loadSkin( _skin, _skinPath );
			}
			else if( _skin ) {
			   // Set the skin based on a MovieClip.
			   setSkin( getSkin( _skin ) );		
			}
      }

      /**
       * Loads an external skin.
       *
       * @param - The original skin (can be null).
       * @param - The path to the external skin.
       */
      public function loadSkin( _skin:MovieClip, _skinPath:String )
      {
         skin = _skin;
         skinPath = _skinPath;
         
         if( skinPath ) {
            if( swfLoader ) {
               // If there already is a skin, then unload it.            
               swfLoader.unload();
            }
            else {
               // Load the SWF file.
               loadSWF();
            }
         }
      }

      /**
       * Loads a SWF file into a loader.
       */
      public function loadSWF()
      {
         createLoader();
         
         try {
            swfLoader.load( new URLRequest( skinPath ) );
         } catch (error:Error) {
            errorHandler( null );
         }            
      }

      /**
       * Creates a loader for the SWF.
       */
      public function createLoader()
      {
         swfLoader = new Loader();
         swfLoader.contentLoaderInfo.addEventListener( Event.UNLOAD, skinUnloaded );
         swfLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, skinLoaded );
         swfLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );   
      }

      /**
       * Called when a skin has been unloaded.
       */
      public function skinUnloaded( event:Event ) : void
      {
         swfLoader=null;
         loadSWF();
      }

      /**
       * Called when a skin has been loaded.
       */
      public function skinLoaded( event:Event )
      {
			rootSkin = MovieClip(swfLoader.content);
			
			// Get the elements skin.
         var newSkin:MovieClip = getSkin( rootSkin );
      
         // Replace any previous skin.
         if( newSkin && skin && skin.parent ) {
            newSkin.x = skin.x;
            newSkin.y = skin.y;
            var index:int = skin.parent.getChildIndex( skin );
            skin.parent.addChildAt( newSkin, index );
            skin.parent.removeChild( skin );		
				
         	if( rootSkin.getLayoutInfo is Function ) {
            	Resizer.addResizeObjects( rootSkin.getLayoutInfo(), newSkin );
         	}			
         }
      
         // Set the new skin.
         setSkin( newSkin );
			
			// Call our callback function if provided.
         if( onSkinLoaded is Function ) {
            onSkinLoaded();
         }			
      }

      public function errorHandler( error:Object )
      {
         trace( error );
         
			// Call our callback function if provided.
         if( onSkinLoaded is Function ) {
            onSkinLoaded();
         }	         
      }

      public function getSkin( _skin:MovieClip ) : MovieClip
      {
         return _skin;
      }

      public function setSkin( _skin:MovieClip )
      {
         skin = _skin;
      }

      public override function get visible():Boolean
      {
         return skin ? skin.visible : false;
      }
      public override function set visible( _visible:Boolean ):void
      {
         if( skin ) {
				skin.visible = _visible;
			}
      }
      public override function set x( _x:Number ):void
      {
			if( skin ) {
         	skin.x = _x;
			}
      }
      public override function get x():Number
      {
         return skin ? skin.x : 0;
      }
      public override function set y( _y:Number ):void
      {
			if( skin ) {
         	skin.y = _y;
			}
      }
      public override function get y():Number
      {
         return skin ? skin.y : 0;
      }
      public override function set scaleX( _scale:Number ):void
      {
			if( skin ) {
         	skin.scaleX = _scale;
			}
      }
      public override function get scaleX():Number
      {
         return skin ? skin.scaleX : 0;
      }
      public override function set scaleY( _scale:Number ):void
      {
			if( skin ) {
         	skin.scaleY = _scale;
			}
      }
      public override function get scaleY():Number
      {
         return skin ? skin.scaleY : 0;
      }
      public override function set width( _width:Number ):void
      {
			if( skin ) {
         	skin.width = _width;
			}
      }
      public override function get width():Number
      {
         return skin ? skin.width : 0;
      }
      public override function set height( _height:Number ):void
      {
			if( skin ) {
         	skin.height = _height;
			}
      }
      public override function get height():Number
      {
         return skin ? skin.height : 0;
      }
      
      public var skin:MovieClip;
		public var rootSkin:MovieClip;
      public var swfLoader:Loader; 		
      private var skinPath:String;  
      private var onSkinLoaded:Function;
   }
}