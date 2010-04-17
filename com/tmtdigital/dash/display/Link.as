/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:   A class for any playlist filter link.
 *
 **/

package com.tmtdigital.dash.display
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.config.Params;   
   import com.tmtdigital.dash.utils.LayoutManager;   
   import com.tmtdigital.dash.net.Gateway;
	import com.tmtdigital.dash.events.DashEvent;

   import flash.display.*;
   import flash.text.*;
	import flash.events.*;
	import flash.net.*;

   public class Link extends Skinable
   {
      public function Link( _skin:MovieClip, _callExternal:Boolean = false, _isButton:Boolean = true )
      {
         isButton = _isButton;
         callExternal = _callExternal;
         query = "";
         arg = "";
         index = 0;
         super( _skin );
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );
         linkText = skin.linkText;
			
			if( linkText ) {
				textColor = linkText.textColor;
			}
			
         setSelected( false );
         setButton();
      }

      public function refresh()
      {
			if( selected ) {
				over();
			}
			else {
				up();
			}
      }

      public function setSelected( _selected:Boolean )
      {
         selected = _selected;
         refresh();
      }

      public function setLink( _text:String, _arg:String, _index:Number )
      {
         if( skin ) {
            arg = _arg;
            index = _index;
				
				if( linkText ) {
					linkText.wordWrap = false;
					linkText.text = _text; 
					linkText.width = linkText.textWidth + LayoutManager.linkpadding;
				}
         }  
      }

      public function setPageLink( _text:String, _query:String, _arg:String )
      {
         if( skin ) {
            arg = _arg;
            query = _query;
				
				if( linkText ) {
					linkText.wordWrap = false;
					linkText.text = _text; 
					linkText.width = linkText.textWidth + LayoutManager.linkpadding;
				}
         }  
      }

      public function set text( _text:String ) 
      {
         if( skin && linkText ) {
            linkText.text = _text;          
         }      
      }
      
      public function get text() : String 
      {
         return linkText ? linkText.text : "";
      }

      public function setButton()
      {
         if( isButton ) {
            skin.buttonMode = true;
            skin.mouseChildren = false;
            skin.addEventListener( MouseEvent.MOUSE_UP, onUp );
            skin.addEventListener( MouseEvent.MOUSE_OUT, onOut );
            skin.addEventListener( MouseEvent.MOUSE_OVER, onOver );
            skin.addEventListener( MouseEvent.MOUSE_DOWN, onDown );
         }
      }

		public function up()
		{
			if( linkText ) {
				linkText.textColor = textColor;
			}
			
			skin.gotoAndStop( "_up" );
		}

		public function over()
		{
			if( linkText ) {
				linkText.textColor = Params.flashVars.taglinkcolor;
			}
			
			skin.gotoAndStop( "_over" );
		}

		public function down()
		{
			if( linkText ) {
				linkText.textColor = textColor;
			}
			
			skin.gotoAndStop( "_down" );
		}

      private function onOut( e:MouseEvent )
      {
         if ( !selected ) {
            up();
         }
      }

      private function onOver( e:MouseEvent )
      {
         if ( !selected ) {
            over();
         }
      }

      private function onDown( e:MouseEvent )
      {
         if ( !selected ) {
            down();
         }
      }

      public function onUp( e:MouseEvent )
      {
         setSelected( true );
         
         if( query ) {
            navigateToURL( new URLRequest( Params.baseURL + query + arg ), "_self" );
         }
         else {
				dispatchEvent( new DashEvent( DashEvent.LINK_CLICK ) );
            Gateway.setFilter( arg, index, callExternal );
         }
      }

      public var linkText:TextField;
      public var selected:Boolean;
      
		public var textColor:uint;
      public var isButton:Boolean;
      public var callExternal:Boolean;
      public var arg:String;
      public var query:String;
      public var index:Number;
   }
}