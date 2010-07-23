/**
 * Fields.as - See class description for information.
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
package com.tmtdigital.dash.display
{
	import com.tmtdigital.dash.DashPlayer;
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.Taxonomy;
   import com.tmtdigital.dash.display.Favorites;
   import com.tmtdigital.dash.display.Menu;
   import com.tmtdigital.dash.display.Image;   
   import com.tmtdigital.dash.display.node.NodeBase;
   import com.tmtdigital.dash.display.ads.TextAd;
   import com.tmtdigital.dash.display.ads.Banner;
   import com.tmtdigital.dash.events.DashEvent;
   import com.tmtdigital.dash.display.media.MediaPlayer;
   import com.tmtdigital.dash.display.voter.DashVoter;
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.utils.Resizer;
   import com.tmtdigital.dash.utils.Files;
   import com.tmtdigital.dash.net.Service;
   import com.tmtdigital.dash.config.Params;

   import flash.display.*;
   import flash.net.*;
   import flash.text.*;
   import flash.events.*;
   import flash.geom.*;

   /**
    * The Fields class is used to keep track of all node fields within the Dash Media Player.
    * This class works as a container for all external data and interaction with that data ( such
    * as media, voters, etc ).
    */
   public class Fields extends Skinable
   {
      /**
       * Constructor for the Fields object.
       *
       * @param skin - The skin to be used for this playlist.
       */    
      public function Fields( _skin:MovieClip, _type:String )
      {
         type = _type;
         super( _skin );
      }

      /**
       * Called from the Skinable class to set the skin for all of the elements within this MovieClip.
       *
       * @param skin - The skin MovieClip for the playlist.
       */ 
      public override function setSkin( _skin:MovieClip )
      {
         super.setSkin( _skin );
         media = new MediaPlayer(_skin.media);
         menu = new Menu(_skin["menu"], type);
         textAd = new TextAd(_skin.textAd);
         banner = new Banner(_skin.banner);
         voter = new DashVoter( _skin.voter, type );
         favorites = new Favorites(_skin.favorites);
         taxonomy = new Taxonomy(_skin.taxonomy);
         selected = !Params.flashVars.teaserplay;
         values = skin.values;
         images = new Array();
         logo = new Image( skin.logo );

         if (skin.views) {
            views = skin.views;
            views.visible = Params.flashVars.viewsenabled;
         }
      }

      /**
       * This function triggers the loading of all fields within the node.
       *
       * @param node - The node object that will be used to populate all of the fields.
       */ 
      public function loadFields( _node:Object )
      {
         node = _node;
         incremented = false;
         files = new Files( node );
			
         // Unload all of our images.
         for( var i:uint=0; i < images.length; i++ ) {
            images[i].clearImage();
         }
			
         // Empty our images array.
         images = new Array();
			
         setFieldsMC();
      }

      /**
       * Used to hide or show the info box.
       *
       * @param show - Boolean to indicate if you would like to show the info box. ( true - show info, false - hide info )
		 * @param tween - Boolean to indicate if you would like to tween the hide/show movement.
		 * @param refresh - Boolean to indicate if you would like to refresh the objects on the screen after the hide/show event.
       */ 
      public function showInfo( show:Boolean, tween:Boolean = false, refresh:Boolean = true )
      {
         if ( rootSkin && (rootSkin.showInfo is Function) && (infoShown != show) ) {
            infoShown = show;
            rootSkin.showInfo( show, tween, refresh );
         }
      }

      protected function setFieldsMC()
      {
         setMediaField();
         setMenuField();
         setAdFields();
         setVoterField();
         setViewsField();
         setFavoritesField();
         setTaxonomyField();
         setValuesField();
      }

      protected function setMediaField()
      {
         // Only want to load the media if it is selected.
         if (media.skin && selected) {
            media.initialize();
            loadMedia();
            loadPreview();
            var loadedMedia:* = media.playNext();
			if( loadedMedia ) {
				loadedMedia.removeEventListener( DashEvent.MEDIA_UPDATE, onMediaUpdate );
				loadedMedia.addEventListener( DashEvent.MEDIA_UPDATE, onMediaUpdate );					
			}
         }
      }

      private function loadPreview() : void
      {
         if( files.hasImage ) {
            // Load the preview image to show...
            var image:Object = files.getFile("image","image_preview");
            
            // No image... let's try another.
            if (! image) {
            
               // If we cannot find that one, then load the original image.
               // The two underscores are intentional. "_original" is the filename
               image = files.getFile("image","image__original");
            }
            
            // Still no image... let's just try any image..
            if (! image) {
               image = files.getFile("image");
            }

            // Now load the preview.
            media.loadPreview( image );
         }
      }

      private function loadMedia()
      {
         if( files.hasMedia ) {
            media.addMediaToQueue( files.getFile( "intro" ) );
            media.addMediaToQueue( files.getFile( "commercial" ) );
            media.addMediaToQueue( files.getFile( "prereel" ) );
   			
            var mediaFile:Object = files.getFile( "media" );
            media.addMediaToQueue( mediaFile );
            setUserStatus( mediaFile );
   			
            media.addMediaToQueue( files.getFile( "postreel" ) );
         }
      }

      private function setUserStatus( mediaFile:Object )
      {
         if( mediaFile && Params.flashVars.trackuser && Service.user && Service.user.userid ) {
            var userVerb:String = "";
            if( mediaFile.mediatype == "video" ) {
               userVerb = "watching";
            }
            else if( mediaFile.mediatype == "audio" ) {
               userVerb = "listening to";
            }
				
            if( userVerb ) {
               Service.call( Service.SET_USER_STATUS, null, null, userVerb, node.title );
            }
         }			
      }

      protected function onMediaUpdate(e:DashEvent)
      {
         if (Params.flashVars.viewsenabled && (e.target.playheadTime > Params.flashVars.incrementtime) && !incremented) {
            incremented = true;
            Service.call( Service.INCREMENT_NODE_COUNTER, setViewsField, null, node.nid );
         }
      }

      protected function setMenuField()
      {
         if (menu.skin) {
            menu.loadMenu();
         }
      }
		
      protected function setAdFields()
      {
         if (textAd.skin) {
            textAd.loadAd();
         }

         if (banner.skin) {
            banner.loadAd();
         }
      }

      protected function setVoterField()
      {
         if ( node.nid && voter.skin && Params.flashVars.votingenabled) {
            voter.loadVoter( node );
         }
      }

      protected function setTaxonomyField()
      {
         if (taxonomy.skin && Params.flashVars.taggingenabled) {
            taxonomy.loadTaxonomy( node );
         }
      }
      protected function setFavoritesField()
      {
         if (favorites.skin) {
            favorites.loadFavs( node );
         }
      }

      protected function setViewsField( count:Number = 0 )
      {
         if (views && Params.flashVars.viewsenabled) {
            var countSring:String = count ? String(count):node["node_counter"];
            var nodeCount:String = node["node_counter"] ? countSring:"0";
            setFieldMC( views["value"], nodeCount );
         }
      }

      protected function setValuesField()
      {
         if (values) {
            var i:int = values.numChildren;
            while (i--)
            {
               var fieldMC:* = values.getChildAt(i);
               if (fieldMC && fieldMC.name) {
                  if (node[fieldMC.name + "_link"]) {
                     setFieldMC( fieldMC, node[fieldMC.name], node[fieldMC.name + "_link"] );
                  }
                  else if ( node["field_" + fieldMC.name + "_link"] ) {
                     setFieldMC( fieldMC, node[fieldMC.name], node["field_" + fieldMC.name + "_link"] );
                  }
                  else {
                     setFieldMC( fieldMC, node[fieldMC.name] );
                  }
               }
            }
         }
      }

      protected function setFieldMC( fieldObject:*, fieldValue:*, linkValue:* = null )
      {
         if (fieldObject) {
            if (fieldObject.name.indexOf("image") == 0) {
               setImageMC( fieldObject );
               if (linkValue) {
                  fieldObject.buttonMode = true;
                  fieldObject.mouseChildren = false;
                  fieldObject.addEventListener( MouseEvent.CLICK, onLinkClick );
               }
            }
            else if ( fieldObject.hasOwnProperty("text") ) {
               if (fieldValue) {
                  linkValue = getFieldValue(linkValue);
                  if (linkValue) {
                     var linkText:String = "<a href='" + linkValue + "'>";
                     linkText += getFieldValue(fieldValue);
                     linkText+="</a>";
                     fieldObject.htmlText=linkText;
                  }
                  else {
                     setTextMC( fieldObject, fieldValue );
                  }
               }
               else {
                  fieldObject.text="";
               }
            }
            else if ( (fieldObject is MovieClip) && linkValue ) {
               fieldObject.buttonMode=true;
               fieldObject.mouseChildren=false;
               fieldObject.addEventListener( MouseEvent.CLICK, onLinkClick );
            }
         }
      }

      protected function setTextMC( fieldObject:*, fieldValue:* )
      {
         setText( fieldObject, getFieldValue(fieldValue) );
      }

      private function getFieldValue( fieldValue:* )
      {
         if (fieldValue) {
            if (fieldValue is String) {
               return fieldValue;
            }
            else if ( (fieldValue is Array) && (fieldValue[0] is Object) && (fieldValue[0]["value"] is String) ) {
               return fieldValue[0]["value"];
            }
         }

         return "";
      }

      private function onLinkClick( event:MouseEvent )
      {
         var fieldName:String=event.target.name+"_link";
         var linkURL:String=getFieldValue(node[fieldName]);

         if (! linkURL) {
            // Try it with "field_" in front...
            linkURL=getFieldValue(node["field_"+fieldName]);
         }

         if (linkURL) {
            navigateToURL( new URLRequest( linkURL ), '_blank' );
         }
      }

      protected function setText( fieldObject:*, fieldValue:* )
      {
         if (fieldObject.hasOwnProperty("text")) {
            fieldObject.text=fieldValue;
         }
      }

      protected function setImageMC( fieldObject:* )
      {
         if( files.hasImage ) {
            var image:Object=files.getFile("image",fieldObject.name);
            if (! image) {
               image=files.getFile("image");
            }
            
            fieldObject = new Image( fieldObject );
            fieldObject.loadImage( (image ? image.path : "") );
            images.push( fieldObject );
         }
      }

      public function preResize()
      {
         if (media) {
            media.preResize();
         }
      }

      public function postResize()
      {
         if (media) {
            media.postResize();
         }
			if( logo && logo.skin && Params.flashVars.logo ) {
         	setLogoPos();
			}
      }

      public function loadLogo()
      {
         if( logo && logo.skin && Params.flashVars.logo ) {
            if (Params.flashVars.link) {
               logo.skin.buttonMode=true;
               logo.skin.mouseChildren=false;
               logo.skin.addEventListener( MouseEvent.MOUSE_UP, Utils.gotoUserWebsite );
            }
            
            logo.loadImage( Params.flashVars.logo, onLogoLoaded, false );
         }
      }

      private function onLogoLoaded()
      {
         if( logo.skin && Params.flashVars.logowidth ) {
            var ratio:Number=logo.skin.width/logo.skin.height;
            logo.skin.width=Params.flashVars.logowidth;
            logo.skin.height=Params.flashVars.logowidth/ratio;
         }

         setLogoPos( true );
      }

      public function setLogoPos( addObject:Boolean = false, dashLogo:DashLogo = null )
      {
			if ( !DashPlayer.valid && dashLogo ) {
				dashLogo.x=2;
				dashLogo.y=2;
				if ( values || (media && media.mediaRegion) ) {
					var bot:Number = values ? (values.y + values.height) : (media.mediaRegion.y + media.mediaRegion.height);
					dashLogo.y = bot - (dashLogo.height + 2);
				}
				
				if ( (dashLogo is MovieClip) && addObject ) {
					Resizer.addResizeProperty( dashLogo, "dash/logo", "y" );
				}			
			} else if ( rootSkin && (rootSkin.setLogoPos is Function) ) {
				rootSkin.setLogoPos( addObject );
			}
      }

      public function hideShow()
      {
         showInfo( Params.flashVars.showinfo );

         if (media) {
            media.hideShow();
         }
      }

      public var values:Sprite;
      public var views:Sprite;
      public var media:MediaPlayer;
      public var menu:Menu;
      public var textAd:TextAd;
      public var banner:Banner;
      public var voter:DashVoter;
      public var favorites:Favorites;
      public var taxonomy:Taxonomy;
      public var logo:Image;
      public var files:Files;
      public var images:Array;
      public var infoShown:Boolean=true;
      public var selected:Boolean;
      private var node:Object;
      private var type:String;
      private var incremented:Boolean=false;
   }
}