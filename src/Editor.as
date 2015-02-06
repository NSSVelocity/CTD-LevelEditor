package
{
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import editors.editorMap;
	import editors.editorMonsters;
	import editors.EditorWindow;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import level.Level;
	
	/**
	 * Main Editor managment class.
	 * @author Velocity (Jonathan)
	 */
	public class Editor extends Sprite
	{
		private var stage_width:Number;
		private var stage_height:Number;
		
		// Level Objects
		public var level_object:Level = new Level();
		
		// Menu Objects
		private var menu_items_text:Array = ["Map Objects", "Editor Monsters", "Loot", "Pickpocket", "Waves", "Export"];
		private var menu_window:Panel;
		private var menu_items:Vector.<PushButton>;
		
		// Editor Objects
		public static var map_image:Loader;
		private var editor:EditorWindow;
		
		/**
		 * Creates a new Editor window. The main class of the application.
		 */
		public function Editor()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Handles the initialation of the Editor.
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Init Level 
			level_object.fromJSON('{"paths":{"1":{"id":1,"points":{"1":{"pos":1,"x":818,"y":194},"2":{"pos":2,"x":376,"y":274},"3":{"pos":3,"x":351,"y":283},"4":{"pos":4,"x":326,"y":291},"5":{"pos":5,"x":304,"y":305},"6":{"pos":6,"x":284,"y":323},"7":{"pos":7,"x":271,"y":344},"8":{"pos":8,"x":301,"y":493}}},"2":{"id":2,"points":{"1":{"pos":1,"x":818,"y":216},"2":{"pos":2,"x":376,"y":298},"3":{"pos":3,"x":356,"y":307},"4":{"pos":4,"x":331,"y":315},"5":{"pos":5,"x":309,"y":329},"6":{"pos":6,"x":295,"y":346},"7":{"pos":7,"x":297,"y":370},"8":{"pos":8,"x":323,"y":493}}},"3":{"id":3,"points":{"1":{"pos":1,"x":818,"y":239},"2":{"pos":2,"x":376,"y":321},"3":{"pos":3,"x":358,"y":328},"4":{"pos":4,"x":340,"y":339},"5":{"pos":5,"x":323,"y":352},"6":{"pos":6,"x":315,"y":370},"7":{"pos":7,"x":318,"y":390},"8":{"pos":8,"x":343,"y":492}}},"4":{"id":4,"points":{"1":{"pos":1,"x":196,"y":-13},"2":{"pos":2,"x":301,"y":493}}},"5":{"id":5,"points":{"1":{"pos":1,"x":218,"y":-13},"2":{"pos":2,"x":323,"y":493}}},"6":{"id":6,"points":{"1":{"pos":1,"x":240,"y":-13},"2":{"pos":2,"x":343,"y":492}}}},"spots":[{"id":1,"x":332,"y":155,"units":5,"range":125,"tower":{"x":-76,"y":22,"spawn_position":1}},{"id":2,"x":525,"y":190,"units":5,"range":125,"tower":{"x":16,"y":76,"spawn_position":1}}],"monsters":[{"name":"HUNTER","id":1},{"name":"BOAR","id":2},{"name":"BEAR","id":3}],"loot":{"common":{"chance":0.8,"items":[{"name":"MONEY","chance":1,"type":"copper","amountMin":5,"amountMax":11}]},"monsters":[{"monster_type":"TYPE_BEAR_HUNTER","chance_increase":0.1,"items":[{"name":"MONEY","chance":0.2,"type":"copper","amountMin":5,"amountMax":11},{"name":"MISC_PIG_FEED","chance":0.6}]},{"monster_type":"TYPE_BEAR_BROWN","chance_increase":0.2,"items":[{"name":"MISC_BEAR_CLAW","chance":0.6}]},{"monster_type":"TYPE_BOAR_GREY","chance_increase":0,"items":[{"name":"MISC_BOAR_RIBS","chance":0.7}]}],"special":{"loot_chance_reset":0,"loot_chance_increase":0.05,"items":[{"name":"HEAD_2_LEATHER_BROWN_HOOD","chance":0.17},{"name":"STAFF_3_LEVEL_2","chance":0.34},{"name":"SWORD_1_LEVEL_2","chance":0.5},{"name":"GUN_1_HUNTER","chance":0.67},{"name":"FEET_7_CLOTH_HUNTERS","chance":0.84},{"name":"SHOULDER_1_MAIL_BANDIT_WHITE_SPIKES","chance":1}]}},"waves":{"1":{"id":1,"type":"","wave_delay":100},"2":{"id":2,"type":"BOAR","lane":5,"node":1,"reversed":false,"wave_delay":100},"3":{"id":3,"type":"BOAR","lane":4,"node":1,"reversed":false,"wave_delay":100},"4":{"id":4,"type":"BOAR","lane":6,"node":1,"reversed":false,"wave_delay":300},"5":{"id":5,"type":"BOAR","lane":2,"node":1,"reversed":false,"wave_delay":100},"6":{"id":6,"type":"BOAR","lane":1,"node":1,"reversed":false,"wave_delay":100},"7":{"id":7,"type":"BOAR","lane":3,"node":1,"reversed":false,"wave_delay":300,"end_of_wave":true},"8":{"id":8,"type":"HUNTER","lane":5,"node":1,"reversed":false,"wave_delay":100},"9":{"id":9,"type":"HUNTER","lane":2,"node":1,"reversed":false,"wave_delay":300},"10":{"id":10,"type":"BOAR","lane":5,"node":1,"reversed":false,"wave_delay":50},"11":{"id":11,"type":"BOAR","lane":4,"node":1,"reversed":false,"wave_delay":50},"12":{"id":12,"type":"BOAR","lane":6,"node":1,"reversed":false,"wave_delay":50},"13":{"id":13,"type":"BOAR","lane":5,"node":1,"reversed":false,"wave_delay":50},"14":{"id":14,"type":"BOAR","lane":4,"node":1,"reversed":false,"wave_delay":50},"15":{"id":15,"type":"BOAR","lane":6,"node":1,"reversed":false,"wave_delay":300,"end_of_wave":true},"16":{"id":16,"type":"BEAR","lane":5,"node":1,"reversed":false,"wave_delay":300},"18":{"id":18,"type":"BOAR","lane":5,"node":1,"reversed":false,"wave_delay":100},"19":{"id":19,"type":"BOAR","lane":4,"node":1,"reversed":false,"wave_delay":100},"20":{"id":20,"type":"BOAR","lane":6,"node":1,"reversed":false,"wave_delay":150},"21":{"id":21,"type":"HUNTER","lane":5,"node":1,"reversed":false,"wave_delay":300,"end_of_wave":true},"22":{"id":22,"type":"BEAR","lane":2,"node":1,"reversed":false,"wave_delay":300},"23":{"id":23,"type":"HUNTER","lane":5,"node":1,"reversed":false,"wave_delay":100},"24":{"id":24,"type":"HUNTER","lane":6,"node":1,"reversed":false,"wave_delay":50},"25":{"id":25,"type":"BOAR","lane":4,"node":1,"reversed":false,"wave_delay":50},"26":{"id":26,"type":"BOAR","lane":5,"node":1,"reversed":false,"wave_delay":50},"27":{"id":27,"type":"BOAR","lane":6,"node":1,"reversed":false,"wave_delay":50,"end_of_wave":true}}}');
			
			// Get Screen Size
			updateSize();
			
			// Draw Items
			drawMenu();
			
			// Resizing
			stage.addEventListener(Event.RESIZE, e_stageResize);
		}
		
		/**
		 * Handles the stage resize event. Updates editor component sizes.
		 * @param	e Passed resize event.
		 */
		private function e_stageResize(e:Event):void
		{
			updateSize();
			resize();
		}
		
		/**
		 * Gets the new stage sizes and classes the resize functions.
		 */
		public function updateSize():void
		{
			stage_width = stage.stageWidth;
			stage_height = stage.stageHeight;
			
			// Min Size
			if (stage_width < 800)
				stage_width = 800;
			if (stage_height < 600)
				stage_height = 600;
		}
		
		/**
		 * Calls the resize functions for all components.
		 */
		public function resize():void
		{
			resizeMenu();
			resizeEditor();
		}
		
		//------------------------------------------------------------------------------------------------------//
		// Menu
		//------------------------------------------------------------------------------------------------------//
		
		/**
		 * Creates the menu items, then resizes them to fit
		 */
		public function drawMenu():void
		{
			// Create Window
			menu_window = new Panel(this, 5, 5)
			
			// Create Buttons
			menu_items = new Vector.<PushButton>();
			
			var button:PushButton;
			for (var index:int = 0; index < menu_items_text.length; index++)
			{
				button = new PushButton(menu_window, 5, 5, menu_items_text[index], e_menuClick);
				button.tag = index;
				menu_items.push(button);
			}
			
			// Update Size
			resizeMenu();
		}
		
		/**
		 * Resizes the menu components.
		 */
		public function resizeMenu():void
		{
			// Set Window Size
			menu_window.setSize(stage_width - 10, 30);
			
			// Set Button Size
			var button_width:int = (menu_window.width / menu_items.length) - 5;
			for (var index:int = 0; index < menu_items.length; index++)
			{
				var button:PushButton = menu_items[index];
				
				button.setSize(button_width, 20);
				button.move((button_width + 5) * index + 5, 5);
			}
		}
		
		/**
		 * Handles the MouseClick Event for Menu Buttons.
		 */
		private function e_menuClick(e:Event):void
		{
			var target:PushButton = (e.target as PushButton);
			
			switch (target.tag)
			{
				// Map Objects
				case 0: 
					drawEditor(new editorMap(level_object));
					break;
				
				// Editor Monsters
				case 1: 
					drawEditor(new editorMonsters(level_object));
					break;
				
				// Loot
				case 2: 
					break;
				
				// Pickpocket
				case 3: 
					break;
				
				// Waves
				case 4: 
					break;
				
				// Export
				case 5: 
					trace(level_object.toJSON());
					break;
			}
		}
		
		//------------------------------------------------------------------------------------------------------//
		// Editors
		//------------------------------------------------------------------------------------------------------//
		public function drawEditor(_editor:EditorWindow):void
		{
			// Remove Old
			if (editor)
			{
				editor.destroy();
				removeChild(editor);
				editor = null;
			}
			
			// Set New Editor
			editor = _editor;
			editor.x = 5;
			editor.y = 40;
			addChild(editor);
			
			// Setup
			resizeEditor();
		}
		
		public function resizeEditor():void
		{
			if (editor)
				editor.resize(stage_width - 10, stage_height - 45);
		}
	
	}

}