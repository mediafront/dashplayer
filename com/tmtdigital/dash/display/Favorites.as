/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  Functionality for having adding, getting, and removing favorite nodes.
 *
 **/

package com.tmtdigital.dash.display
{
   import com.tmtdigital.dash.display.Skinable;
   import com.tmtdigital.dash.display.controls.ToggleButton;
   import com.tmtdigital.dash.net.Service; 
   
   import flash.display.*;

   public class Favorites extends Skinable
   {
      public function Favorites( _skin:MovieClip )
      {
         super( _skin );
      }

      public override function setSkin(_skin:MovieClip)
      {
         super.setSkin( _skin );
         addDelete = new ToggleButton( skin.addDelete, setFavorite, true, false );
      }

      /**
             * Loads the favorites for the given node object.
             *
             * @param - The actual node object in which you would like to load the favorites.
             */
      public function loadFavs( _node:Object )
      {
         node = _node;
         getIsFavorite();
      }

      /**
             * Call the "IsFavorite" service method.
             */
      public function getIsFavorite()
      {
         Service.call( Service.IS_FAVORITE, onIsFavorite, null, node.nid );
      }

      /**
             *  Call the "SetFavorite" service method.
             *
             * @param - The boolean to say if this node is a favorite or not.
             */
      public function setFavorite(favorite:Boolean)
      {
         var command:String = favorite ? Service.SET_FAVORITE:Service.DELETE_FAVORITE;
         Service.call( command, null, null, node.nid );
      }

      /**
             * Called when the service call returns if this node is a favorite or not.
             *
             * @param - The value of if this node is a favorite.
             */
      public function onIsFavorite( isFavorite:Number )
      {
         addDelete.setState( ( isFavorite > 0 ) );
      }

      private var node:Object;
      private var addDelete:ToggleButton;
   }
}