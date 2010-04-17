/*
  Plymedia
  Created by Elizabeth Marr on 2009-09-09.
  Copyright (c) 2009 Plymedia.com . All rights reserved.
*/
package com.tmtdigital.dash.display.media
{
	import com.tmtdigital.dash.DashPlayer;
	import com.tmtdigital.dash.config.Params;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;

	import flash.system.SecurityDomain;
	import flash.system.LoaderContext;

	public class Plymedia extends Sprite
	{
		private static const CLASS:String = "[com.tmtdigital.dash.display.media.Plymedia]";

		private var ply:Object;

		private var loaded:Boolean = false;
		private var video:String;
		private var w:Number;
		private var h:Number;
		private var time:Number;

		public function Plymedia():void
		{
			init();
		}

		private function init():void
		{
			var ldr     :Loader         = new Loader();
			var cx:LoaderContext = new LoaderContext();
			cx.securityDomain = SecurityDomain.currentDomain;
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onPlyLoaded);
			ldr.load( new URLRequest(Params.flashVars.subplypath));
			addChild(ldr);
		}

		private function onPlyLoaded(event:Event):void
		{
			loaded = true;
			ply = event.target.content;

			if (video != null) {
				ply.setByVideoPath(video);
			}
			if (! isNaN(time)) {
				ply.updateTime(time);
			}
			if (! isNaN(w)) {
				ply.resize(w,h);
			}

			ply.addEventListener("PAUSE" , reportVideoEventHandler);
			ply.addEventListener("PLAY" , reportVideoEventHandler);
		}

		public function setVideo(str:String):void
		{
			if (loaded) {
				ply.setByVideoPath(str);
			}
			else {
				video = str;
			}
		}

		public function updateTime(tm:Number):void
		{
			if (loaded) {
				ply.updateTime(tm);
			}
			else {
				time = tm;
			}
		}

		public function resize($w:Number,$h:Number, auxH:Number):void
		{
			var $width:Number = $w;
			var $height :Number = (DashPlayer.getStage().displayState == StageDisplayState.FULL_SCREEN)? $h - auxH : $h;

			if (loaded) {
				ply.resize($width,$height);
			}
			else {
				w = $width;
				h = $height;
			}
		}


		private function reportVideoEventHandler(e:Event):void
		{
			switch (e.type) {
				case "PAUSE" :
					break;
				case "PLAY" :
					break;
			}
		}

	}

}