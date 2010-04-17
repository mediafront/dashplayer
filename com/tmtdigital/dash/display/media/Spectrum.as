/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The Preview class is used to manage the preview screen
 * within the media region of the player. 
 *
 **/

package com.tmtdigital.dash.display.media
{
   import com.tmtdigital.dash.display.Skinable; 
   import com.tmtdigital.dash.utils.Utils;
	import com.tmtdigital.dash.config.Params;

   import flash.display.*;

   class Spectrum extends Skinable
   {
      public function Spectrum( _skin:MovieClip, _onLoaded:Function = null )
      {
         var spectrumURL:String = "";
         
			if( Params.flashVars.spectrum && _skin ) { 
			   _skin.visible = false;        
            spectrumURL = Params.getRootPath();
            spectrumURL += "/plugins/spectrums/";
            spectrumURL += Params.flashVars.spectrum + "/";
            spectrumURL += Params.flashVars.spectrum + ".swf";	
         }		
			
         super( _skin, spectrumURL, _onLoaded );
      }

      public override function getSkin( newSkin:MovieClip ) : MovieClip
      {
         if( rootSkin && (rootSkin.getSpectrum is Function) ) {
            return rootSkin.getSpectrum(320, 240);
         }
         
         return newSkin;         
      }
		
      public function postResize( _width:Number, _height:Number )
      {
         if( rootSkin && (rootSkin.resizeSpectrum is Function) ) {
            return rootSkin.resizeSpectrum( _width, _height );
         }			
      }
   }
}