/**
 * Copyright 2008 - TMTDigital LLC
 *
 * Author:   Travis Tidwell (www.travistidwell.com)
 * Version:  1.0
 * Date:     June 9th, 2008
 *
 * Description:  The Resizer class is a class that allows for dynamic resizing of any MovieClip by providing an
 *               XML file that indicates all the dynamic objects and their properties in the clip.
 **/

package com.tmtdigital.dash.utils
{
   import com.tmtdigital.dash.DashPlayer;	
   import com.tmtdigital.dash.utils.Utils;
   import com.tmtdigital.dash.config.Params;

   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.geom.*;
   import fl.transitions.*;
   import fl.transitions.easing.*;

   public class Resizer
   {
      /**
       *  Loads the Layout file used for the dynamic resizing.
       *
       *  @param  -  String (file) or XML representation of the layout used for resizing this player.
       *
       **/
      public static function loadLayout( layout:XML )
      {
         tweenTime = Params.flashVars.tweentime;
         addResizeObjects( layout, DashPlayer.skin.dash );
      }

      /**
       *  Allows you to add a dynamic object in the LayoutManagers Dynamic Objects Array.  This array is what is used to dynamically resize
       *  and move certain objects in the system.  You can simply pass the path of the object that needs to be resized or moved dynamically 
       *  followed by the parameter that will be dynamically changing ("width", "height", "x", or "y")
       *
       *  @param  -  The dynamic object.
       *  @param  -  The property of that object that you would like to have dynamically changed.  ("width", "height", "x", or "y")
       *
       **/
      public static function addResizeProperty( obj:*, _path:String, _param:String )
      {
         if (obj) {
            var resizeObject:Object = new Object();
            resizeObject.object = obj;
            resizeObject.propValue = obj[_param];
            resizeObject.layout = {path:_path,property:_param};
            resizeObject.tween = new Tween(obj,_param,tweenFunction,obj[_param],obj[_param],tweenTime);
            resizeObject.tween.stop();
            resizeObjects.push( resizeObject );
         }
      }

      /**
       *  Adds all of the resize objects given an XML structure of all resize elements.
       *
       *  @param  -  The XML of the layout information.
       *  @param  -  The skin to add these resize objects too.
       *
       **/
		public static function addResizeObjects( layout:XML, _skin:MovieClip )
		{
			for each (var element in layout.resize) {
            var obj:* = Utils.getObjectFromPath( _skin, element.path );
				var prefix:String = element.hasOwnProperty("prefix") ? element.prefix : "";
         
            if (obj) {
					for each (var property in element.property) {
                  addResizeProperty( obj, (prefix + element.path), property );
               }
            }
         }		
		}

      /**
       *  Used to set a property of an element in our dynamics objects array.  It is imperitive that you use this function when you wish to set
       *  any "x", "y", "width", or "height" property of an element that is in the dynamic objects array.  Otherwise, the value will get overridden
       *  when the player is resized.
       *
       *  @param  -  The actual object you would like to have the property set.
       *  @param  -  The path to your dynamic object.
       *  @param  -  The property of that object that you would like to have dynamically changed.  ("width", "height", "x", or "y")
       *  @param  -  The value to set the property too.
       *
       **/
      public static function setResizeProperty( obj:*, path:String, property:String, value:Number, tween:Boolean = false ):void
      {
         if ( obj && (path != "dash/logo") ) {
            // First set the actual property of that object.
            if (! tween) {
               obj[property] = value;
            }

            // Now lets locate the object in the dynamic objects array.
            for each (var resizeObject:Object in resizeObjects) {
               if ( (resizeObject.layout.path == path) && (resizeObject.layout.property == property) ) {
                  if (tween) {
                     resizeObject.tween.stop();
                     resizeObject.tween.begin = obj[property];
                     resizeObject.tween.finish = (value >= 0) ? value : 0;
                     resizeObject.tween.start();
                  }

                  // And set the property value in the dynamic objects array.
                  resizeObject.propValue = value;
                  break;
               }
            }
         }
      }

      /**
       *  Function that allows you to resize any object while maintaining the correct proportions of all child elements.
       *
       *  @param  -  The actual object you would like to have the property set.
       *  @param  -  The string path of the object.
       *  @param  -  The new width you would like to set the object too.
       *  @param  -  The new height you would like to set the object too.
       *  @param  -  Should we tween this resize?
       *
       **/
      public static function resizeObject( mc:*, path:String, newWidth:Number, newHeight:Number, tween:Boolean = false, refresh:Boolean = true )
      {
         if (mc) {
            var xOffset:Number = newWidth - mc.width;
            var yOffset:Number = newHeight - mc.height;
            resizeLayout( path, xOffset, yOffset, tween, refresh );
         }
      }

      /**
             * Sets the size of any dynamic object.
             */
      public static function setRect( mc:*, path:String, newRect:Rectangle )
      {
         if (newRect) {
            setResizeProperty( mc, path, "x", newRect.x );
            setResizeProperty( mc, path, "y", newRect.y );
            resizeObject( mc, path, newRect.width, newRect.height, false );
         }
      }

      /**
       *  Governing function over all element resizing.  This function will iterate through all the dynamic objects and change
       *  the property given in the dynamic objects array based on the x and y offset passed to this function.
       *
       *  @param  -  The string path used for filtering an object and its children.  Leave as "" for a complete resize.
       *  @param  -  The offset resize in the X direction.
       *  @param  -  The offset resize in the Y direction
       *  @param  -  Should we tween this resize?
       *
       **/
      public static function resizeLayout( path:String = "", xOffset:Number = 0, yOffset:Number = 0, tween:Boolean = false, refresh:Boolean = true )
      {
         inTransition = refresh;

         if (refresh && (preResize is Function)) {
            preResize();
         }

         var added:Boolean = false;

         for each (var resizeObject:Object in resizeObjects) {
            if ( (path != "dash/logo") && Utils.filterPath(resizeObject.layout.path, path) ) {
               if ( !added && tween && (resizeObject.object is MovieClip) ) {
                  added = true;
                  resizeObject.tween.removeEventListener( TweenEvent.MOTION_FINISH, onResizeFinish );
                  resizeObject.tween.addEventListener( TweenEvent.MOTION_FINISH, onResizeFinish );
               }

               setResizeObject( resizeObject, xOffset, yOffset, tween );
            }
         }

         if (! tween && refresh) {
            onResizeFinish(null);
         }
      }

      /**
       *  Called when the resize has finished.  Immediate if there was not tween involved.
       *
       *  @param  -  The actual tween event that determines when the tween has finished.
       *
       **/
      private static function onResizeFinish(e:TweenEvent)
      {
         inTransition = false;
			
         if( postResize is Function ) {
            postResize();
         }
      }

      /**
       *  Actually sets the properties of the Dynamic Object within the dynamic objects array.
       *
       *  @param  -  The dynamic object to be set.
       *  @param  -  The offset in the X direction to set this property too.
       *  @param  -  The offset in the Y direction to set this property too.
       *  @param  -  Should we tween this resize? 
       *
       **/
      private static function setResizeObject( resizeObject:Object, xOffset:Number, yOffset:Number, tween:Boolean = false )
      {
         var prop:String = resizeObject.layout.property;
         var propValue:Number = resizeObject.propValue;
         var newValue:Number = ((prop == "width") || (prop == "x")) ? (propValue + xOffset) : (propValue + yOffset);

         if (tween) {
            resizeObject.tween.stop();
            resizeObject.tween.begin = propValue;
            resizeObject.tween.finish = (newValue >= 0) ? newValue : 0;
            resizeObject.tween.start();
         } else {
            resizeObject.object[prop] = (newValue >= 0) ? newValue : 0;
         }

         resizeObject.propValue = newValue;
      }

      public static var preResize:Function;
      public static var postResize:Function;
      public static var tweenFunction:Function;
      public static var tweenTime:Number;
      public static var resizeObjects:Array = new Array();

      public static var inTransition:Boolean = false;
   }
}