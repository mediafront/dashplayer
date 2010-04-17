/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The Dash Tagger class is used to govern all tagging in the 
 *                dash player.
 *
 **/

package com.tmtdigital.dash.display
{
	import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.display.Link;
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.net.Service;
	import com.tmtdigital.dash.events.DashEvent;
   import com.tmtdigital.dash.config.Params;    

   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.text.*;

   public class Taxonomy extends Skinable
   {
      public function Taxonomy( _skin:MovieClip )
      {
         super( _skin );
      }

      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );

         terms = skin.terms;
         if( terms ) {
            termsWidth = terms.width;
         }

         submit = skin.submit;
         input = skin.input;
         visible = Params.flashVars.taggingenabled;
      }

      public function loadTaxonomy( _node:Object )
      {
         node = _node;

         if (input) {
            input.text = "";
         }

         if (submit) {
            submit.buttonMode = true;
            submit.mouseChildren = false;
            submit.removeEventListener( MouseEvent.MOUSE_UP, onTagSubmit );
            submit.addEventListener( MouseEvent.MOUSE_UP, onTagSubmit );
         }

         setTaxonomyField();
      }

      protected function onTagSubmit( event:MouseEvent )
      {
         var inputText:String = input.text;

         if (node && node["tagging_vid"] && inputText) {
            DashPlayer.dash.node.spinner.visible = true;
            Service.call( Service.ADD_TAG, onAddTag, null, node.nid, node["tagging_vid"], input.text);
         }
      }

      protected function onAddTag(tags:Object)
      {
         DashPlayer.dash.node.spinner.visible = false;
         input.text = "";
         setTaxonomyField( tags );
      }

      protected function setTaxonomyField( tags:Object = null )
      {
         if ( terms && (rootSkin.getTermLink is Function) ) {
            Utils.removeAllChildren( terms );
            var xPos:Number = 0;
            var yPos:Number = 0;
            var index:Number = 0;
            var nodeTags:Object = tags ? tags:node["taxonomy"];
            var lastTerm:Link = null;

            for each (var tax:Object in nodeTags) {
               if (tax.vid == node["tagging_vid"]) {
                  if (lastTerm) {
                     lastTerm.text = lastTerm.text + ",";
                  }

                  var termSkin:MovieClip = rootSkin.getTermLink();
                  if (termSkin) {
                     var termLink:Link = new Link( termSkin, Params.flashVars.disableplaylist, Params.flashVars.termlinks );
                     termLink.addEventListener( DashEvent.LINK_CLICK, onClicked );
							
                     if( Params.flashVars.pagelink ) {
                        termLink.setPageLink( tax.name, "?q=taxonomy/term/", tax.tid );
                     }
                     else {
                        termLink.setLink( tax.name, tax.tid, 0 );
                     }
                     
                     termLink.x = xPos;
                     termLink.y = yPos;
                     terms.addChild( termLink.skin );
                     var wrap:Boolean = ((xPos + termLink.width) > termsWidth) ? true : false;
                     xPos = wrap ? 0 : (xPos + termLink.width);
                     yPos = wrap ? (yPos + termLink.height + 2) : yPos;
                     lastTerm = termLink;
                     index++;
                  }
               }
            }
         }
      }

		private function onClicked( e:DashEvent )
		{
			if( currentLink ) {
				currentLink.setSelected( false );
			}
			
			currentLink = (e.target as Link);
		}

      public var submit:MovieClip;
      public var terms:MovieClip;
      public var input:TextField;
      private var termsWidth:Number;
		private var currentLink:Link = null;
      private var node:Object;
   }
}