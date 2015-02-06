package
{
	import com.bit101.components.Style;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	/**
	 * Main entry point for thte editor.
	 * @author Velocity (Jonathan)
	 */
	public class Main extends Sprite
	{
		
		public function Main()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Set Resize Mode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//stage.color = 0x111111;
			//Style.setStyle(Style.DARK);
			
			// Add Editor
			addChild(new Editor());
		}
	
	}

}