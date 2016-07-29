package com {
	import com.giveawaytool.meta.MetaCountdownConfig;
	import com.giveawaytool.meta.MetaGiveawayConfig;
	import com.lachhh.utils.Utils;
	import com.lachhh.flash.FlashUtils;
	/**
	 * @author LachhhSSD
	 */
	public class MetaIRCMessage {
		public var rawMsg:String;
		public var name:String;
		public var text:String;
		public var resubName:String = "";
		public var resubMonths:int = -1;
		
		public function MetaIRCMessage() {
		}
		
		public function isNotificationFromTwitch():Boolean {
			return (name == "twitchnotify") || (name == "jtv");
		}
		
		public function isMoobot():Boolean {
			return name == "moobot";
		}
		
		public function isCountdownAutoClaimCmd(m:MetaCountdownConfig):Boolean {
			if(isNotificationFromTwitch()) return false;
			if(!isNameEquals(m.target)) return false;
			return true;
		}
		
		public function isGiveawayAutoAddCmd(m:MetaGiveawayConfig):Boolean {
			if(isNotificationFromTwitch()) return false;
			return m.isEqualToCmd(text);
		}
		
		public function isHostAlert():Boolean {
			if(!isNotificationFromTwitch()) return false;
			return text.indexOf("is now hosting you") >= 0;
		}
		
		public function isNewSubAlert():Boolean {
			if(!isNotificationFromTwitch()) return false;
			if(text.indexOf("subscribed for") >= 0) return true;
			return text.indexOf("just subscribed!") >= 0;
		}
		
		public function isReSubAlert():Boolean {
			if(!isNotificationFromTwitch()) return false;
			return resubMonths > 0;
		}
		
		public function getHostName():String {
			if(!isHostAlert()) return "";
			var data:Array = text.split(" ");
			return data[0];
		}
		
		public function getHostViewerCount():int {
			if(!isHostAlert()) return 0;
			var data:Array = text.split(" ");
			return FlashUtils.myParseFloat(data[6]);
		}
		
		public function getSubName():String {
			if(!isReSubAlert() && !isNewSubAlert()) return "";
			
			if(resubName != null && resubName != ""){
				return resubName;
			} else {
				var data:Array = text.split(" ");
				return data[0];
			}
		}
		
		public function getResubMonth():int {
			if(!isReSubAlert()) return 0;
			return resubMonths;
		}
		
		public function isNameEquals(pName:String):Boolean {
			if (pName == null) return false;
			if (name == null) return false;
			pName = Utils.removeTextNewLine(pName);
			return (name.toLowerCase() == pName.toLowerCase());
		}
		
		static public function isPing(msg:String):Boolean {
			return (msg.indexOf("PING :tmi.twitch.tv") == 0);
		}
		
		static public function createDummyHost():MetaIRCMessage {
			var result:MetaIRCMessage = new MetaIRCMessage();
			result.name = "twitchnotify";
			result.text = "TheDude is now hosting you.";
			return result;
		}
		
		//:larklen!larklen@larklen.tmi.twitch.tv PRIVMSG #kojaktsl :So now you are just filtering for the appropriate tag
		
		//@badges=moderator/1,subscriber/1,turbo/1;color=#00997F;display-name=HiimMikeGaming;emotes=496:23-24;id=19c51976-19c1-455e-abd4-14de2f8af796;mod=1;room-id=58573465;subscriber=1;turbo=1;user-id=44573777;user-type=mod :hiimmikegaming!hiimmikegaming@hiimmikegaming.tmi.twitch.tv PRIVMSG #kojaktsl :Larklen, no they don't :D
		
		//@badges=staff/1,broadcaster/1,turbo/1;color=#008000;display-name=TWITCH_UserName;emotes=;mod=0;msg-id=resub;msg-param-months=6;room-id=1337;subscriber=1;system-msg=TWITCH_UserName\shas\ssubscribed\sfor\s6\smonths!;login=twitch_username;turbo=1;user-id=1337;user-type=staff :tmi.twitch.tv USERNOTICE #channel :Great stream -- keep it up!
		
		static public function createFromRawData(msg:String):MetaIRCMessage {
			var result:MetaIRCMessage = new MetaIRCMessage();
			
			if(msg.charAt(0) == "@"){
				return parseLongMsg(msg, result);
			}
			
			if(msg.charAt(0) == ":"){
				return parseShortMsg(msg, result);
			}
			
			return parseShortMsg(msg, result);
		}
		
		private static function parseShortMsg(msg:String, result:MetaIRCMessage):MetaIRCMessage{
			
			var nameLength:int = msg.indexOf("!");
			var messageStartIndex:int = msg.indexOf(":", nameLength);
			result.name = msg.substring(1, nameLength); // trim the initial ':'
			result.text = msg.substring(messageStartIndex + 1, msg.length);
			
			var data:Array = result.text.split(" ");
			result.rawMsg = msg;
			result.resubMonths = data[3];
			result.resubName = data[0];
			
			trace(result.isReSubAlert());
			trace(result.name);
			trace(result.text);
			trace(result.resubMonths);
			trace(result.resubName);
			
			return result;
		}
		
		private static function parseLongMsg(msg:String, result:MetaIRCMessage):MetaIRCMessage{
			var msgData:Array = msg.split(";");
			
			var isResubAlert:Boolean = false;
			
			var resubMonths:int = 0;
			var username:String = "";
			
			for(var i:int = 0; i < msgData.length; i++){
				var msgStr:String = msgData[i];
				if(msgStr.indexOf("display-name=") >= 0){
					username = msgStr.replace("display-name=", "");
					continue;
				}
				if(msgStr.indexOf("msg-id=resub") >= 0){
					isResubAlert = true;
					continue;
				}
				if(msgStr.indexOf("msg-param-months=") >= 0){
					resubMonths = int(msgStr.replace("msg-param-months=", ""));
					continue;
				}
			}
			
			if(isResubAlert){
				result.name = "twitchnotify";
				result.text = "";
				result.resubMonths = resubMonths;
				result.resubName = username;
			} else {
				result.name = username;
				result.resubMonths = -1;
				result.resubName = username;
				var lastStrData:Array = msgData[msgData.length - 1].split(":");
				var lastStr:String = lastStrData[lastStrData.length - 1];
				if(lastStr.indexOf("tmi.twitch.tv") >= 0){
					result.text = "";
				} else {
					result.text = lastStr;
				}
			}
			result.rawMsg = msg;
			trace(result.isReSubAlert());
			trace(result.name);
			trace(result.text);
			trace(result.resubMonths);
			trace(result.resubName);
			//var nameLength:int = msg.indexOf("!");
			//var messageStartIndex:int = msg.indexOf(":", nameLength);
			//result.name = msg.substring(1, nameLength); // trim the initial ':'
			//result.text = msg.substring(messageStartIndex + 1, msg.length);
			
			return result;
		}
		
		
		
		static public function isErrorLoggingMsg(msg:String):Boolean {
			return (msg.indexOf(":tmi.twitch.tv NOTICE * :Error logging in") == 0);
		}
		
		public function isModsRequest():Boolean {
			if((rawMsg.indexOf("msg-id=room_mods") != 1)) return false;
			if((rawMsg.indexOf(":The moderators of this room are:") == -1)) return false;
			return true;
		}
		
		static public function isLoggedSuccess(msg:String):Boolean {
			if(msg.indexOf("tmi.twitch.tv 001") == -1) return false;
			return true;
		}

		public function toString() : String {
			return name + ": " + text;
		}
	}
}
