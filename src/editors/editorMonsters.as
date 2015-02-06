package editors
{
	import com.bit101.components.InputText;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	import com.bit101.components.Window;
	import flash.display.Sprite;
	import flash.events.Event;
	import level.Level;
	
	/**
	 * Editor for Monster List
	 * @author Velocity (Jonathan)
	 */
	public class editorMonsters extends EditorWindow
	{
		public var level_object:Level;
		
		private var win:Window;
		private var pan:ScrollPane;
		private var inputs:Array = [];
		
		private var saveButton:PushButton;
		private var addButton:PushButton;
		
		public function editorMonsters(_level_object:Level)
		{
			this.level_object = _level_object;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/**
		 * Inits Editor Window
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Create Windows
			win = new Window(this, 0, 0, "Monster Editor");
			pan = new ScrollPane(win);
			pan.autoHideScrollBar = true;
			
			// Create Buttons
			//saveButton = new PushButton(pan, 10, 10, "Save", e_saveButton);
			addButton = new PushButton(pan, /*120*/10, 10, "Add Monster", e_addButton);
			
			// Add Monsters
			for (var i:int = 0; i < level_object.monsters.length; i++)
			{
				_addMonster(level_object.monsters[i]);
			}
			
			updatePositions();
		}
		
		override public function destroy():void
		{
			e_saveButton();
		}
		
		/**
		 * Creates a new Editor Monster Object
		 * @param	m Optional: Existing Monster Object
		 */
		private function _addMonster(m:Object = null):void
		{
			var nameText:InputText = new InputText(pan, 0, 0, (m ? m["name"] : ""));
			var idText:InputText = new InputText(pan, 0, 0, (m ? m["id"] : _newestID().toString()));
			var delButton:PushButton = new PushButton(pan, 0, 0, "Delete", e_deleteButton);
			
			var tag:Object = {"name": nameText, "id": idText, "del": delButton};
			
			delButton.tag = tag;
			
			inputs.push(tag);
		}
		
		/**
		 * Updates the monster input boxes after an add / remove.
		 */
		private function updatePositions():void
		{
			// Sort by ID
			_sortInput();
			
			// Position Inputs
			for (var i:int = 0; i < inputs.length; i++)
			{
				var tag:Object = inputs[i];
				tag["name"].move(10, 30 * i + 40);
				tag["id"].move(120, 30 * i + 40);
				tag["del"].move(230, 30 * i + 40);
			}
			
			// Update ScrollPane Scroll bars.
			pan.update();
		}
		
		/**
		 * Event: Adds a new Monster
		 */
		private function e_addButton(e:Event):void
		{
			_addMonster();
			updatePositions();
		}
		
		/**
		 * Handles the removing of monsters.
		 */
		private function e_deleteButton(e:Event):void
		{
			var tag:Object = (e.target as PushButton).tag;
			
			pan.removeChild(tag["name"]);
			pan.removeChild(tag["id"]);
			pan.removeChild(tag["del"]);
			
			inputs.splice(inputs.indexOf(tag), 1);
			
			updatePositions();
		}
		
		/**
		 * Handles Saving of the Monsters editor.
		 */
		private function e_saveButton(e:Event = null):void
		{
			_sortInput();
			
			// Build Monster Array
			var o:Array = [];
			for (var i:int = 0; i < inputs.length; i++)
			{
				var monster:Object = inputs[i];
				o.push({"name": monster.name.text, "id": monster.id.text});
			}
			
			level_object.monsters = o;
			
			// Update Positions
			updatePositions();
		}
		
		/**
		 * Sorts the inputs based on ID textbox.
		 */
		private function _sortInput():void
		{
			// Sort by ID
			for (var i:int = 0; i < inputs.length; i++)
			{
				inputs[i]["id_val"] = Number(inputs[i]["id"].text);
			}
			inputs = inputs.sortOn("id_val", Array.NUMERIC);
		}
		
		/**
		 * Provides the next ID.
		 * @return Next ID.
		 */
		private function _newestID():int
		{
			var val:int = 0;
			for (var i:int = 0; i < inputs.length; i++)
			{
				var id:Number = Number(inputs[i]["id"].text);
				if (id > val)
				{
					val = id;
				}
			}
			return val + 1;
		}
		
		/**
		 * Resizes Editor window based on provided sizes.
		 * @param	width
		 * @param	height
		 */
		override public function resize(width:Number, height:Number):void
		{
			win.setSize(width, height);
			pan.setSize(win.width, win.height - 20);
			pan.update();
		}
	
	}

}