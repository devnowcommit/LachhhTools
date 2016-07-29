package com.giveawaytool.ui {
	import com.giveawaytool.ui.views.ViewGenericListWithPages;
	import com.giveawaytool.ui.views.ViewSubscriberBtn;
	import com.giveawaytool.ui.views.ViewSubscriberDynamic;
	import com.giveawaytool.ui.views.ViewSubscriberToolTip;
	import com.lachhh.lachhhengine.ui.UIBase;
	import com.lachhh.lachhhengine.ui.views.ViewBase;

	import flash.display.DisplayObject;

	/**
	 * @author LachhhSSD
	 */
	public class ViewSubscribersList extends ViewGenericListWithPages {
		public var toolTip : ViewSubscriberToolTip;

		public function ViewSubscribersList(pScreen : UIBase, pVisual : DisplayObject) {
			super(pScreen, pVisual);
		}

		override public function createChildView() : ViewBase {
			return new ViewSubscriberDynamic(screen, contentMc);
		}

		override public function refresh() : void {
			super.refresh();
			titleTxt.text = "Subscribers";
			
		}

		override public function onClickView(v : ViewBase) : void {
			super.onClickView(v);
			if(!toolTip) return ;
			toolTip.onClickSubscriberView(v as ViewSubscriberBtn);
		}
	}
}
