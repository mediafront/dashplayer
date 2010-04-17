/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Functionality for the menu section of the Dash Player.
 *
 **/

package com.tmtdigital.dash.display
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.config.Params;   
   
   import flash.text.*;
   import flash.display.*;
   import flash.events.*;

   public class Spinner extends Skinable
   {
      public function Spinner( _skin:MovieClip, _type:String )
      {
			var _skinPath:String = "";
			type = _type;
			
         if( Params.flashVars.spinner ) {
            _skinPath = Params.getRootPath();
            _skinPath += "/plugins/spinners/" + Params.flashVars.spinner + "/spinner.swf";
         }
			
         super( _skin, _skinPath );
      }

      public override function getSkin( newSkin:MovieClip ) : MovieClip
      {
         if( rootSkin && (rootSkin.getSpinner is Function) ) {
            return rootSkin.getSpinner( type );
         }
         
         return newSkin;         
      }

		public override function setSkin( _skin:MovieClip )
		{
			super.setSkin( _skin );
			
			if( initWidth && initHeight ) {
				postResize( initWidth, initHeight );
			}
		}

      public function postResize( _width:Number, _height:Number )
      {
			initWidth = _width;
			initHeight = _height;
			if( rootSkin && ( rootSkin.resizeSpinner is Function ) ) {
				rootSkin.resizeSpinner( type, _width, _height );
			}
			else if( skin ) {
				skin.loader_back.width = _width;
				skin.loader_back.height = _height;
				skin.loader_mc.x = (_width / 2);
				skin.loader_mc.y = (_height / 2);
			}
      }
		
		//public override function set visible( _visible:Boolean ) : void {}
		
      private var type:String;	
		private var initWidth:Number;
		private var initHeight:Number;
   }
}