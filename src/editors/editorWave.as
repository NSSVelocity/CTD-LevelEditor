package editors
{
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	import com.bit101.components.Window;
	import flash.events.Event;
	import level.Level;
	
	/**
	 * Editor for Wave List
	 * @author Velocity (Jonathan)
	 */
	public class editorWave extends EditorWindow
	{
		public var level_object:Level;
		
		private var win:Window;
		private var pan:ScrollPane;
		public var inputs:Array = [];
		
		private var addButton:PushButton;
		
		public function editorWave(_level_object:Level)
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
			win = new Window(this, 0, 0, "Wave Editor");
			pan = new ScrollPane(win);
			pan.autoHideScrollBar = true;
			
			// Create Buttons
			addButton = new PushButton(pan, 10, 10, "Add Wave", e_addButton);
			
			// Add Waves
			for each (var wave:Object in level_object.waves)
			{
				_addWave(wave);
			}
			
			_updatePositions();
		}
		
		override public function destroy():void
		{
			_save();
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
		
		/**
		 * Creates a new Editor Wave Object
		 * @param	m Optional: Existing Wave Object
		 */
		private function _addWave(m:Object = null):void
		{
			var tag:WavePanel = new WavePanel(this, m);
			pan.addChild(tag);
			tag.id = newestID();
			inputs.push(tag);
		}
		
		/**
		 * Updates the wave input boxes after an add / remove.
		 */
		private function _updatePositions():void
		{
			// Sort by ID
			sortInput();
			
			// Position Inputs
			for (var i:int = 0; i < inputs.length; i++)
			{
				inputs[i].x = 10;
				inputs[i].y = 30 * i + 40;
				inputs[i].updateEnabled();
			}
			
			// Update ScrollPane Scroll bars.
			pan.update();
		}
		
		/**
		 * Event: Adds a new Wave
		 */
		private function e_addButton(e:Event):void
		{
			_addWave();
			_updatePositions();
		}
		
		/**
		 * Handles the removing of monsters.
		 */
		public function e_deleteButton(e:Event):void
		{
			var tag:WavePanel = (e.target as PushButton).tag;
			
			pan.removeChild(tag);
			
			inputs.splice(inputs.indexOf(tag), 1);
			
			_updatePositions();
		}
		
		/**
		 * Sorts the inputs based on ID textbox.
		 */
		public function sortInput():void
		{
			inputs.sortOn("id", Array.NUMERIC);
			for (var i:int = 0; i < inputs.length; i++)
			{
				inputs[i]["id"] = (i + 1);
			}
		}
		
		/**
		 * Provides the next ID.
		 * @return Next ID.
		 */
		public function newestID():int
		{
			var val:int = 0;
			for (var i:int = 0; i < inputs.length; i++)
			{
				if (inputs[i]["id"] > val)
				{
					val = inputs[i]["id"];
				}
			}
			return val + 1;
		}
		
		/**
		 * Creates an array for ComboBoxes from the monster types.
		 * @return List Array of Map Paths
		 */
		public function getMonsterTypes():Array
		{
			var o:Array = [];
			
			o.push({"label": "-DELAY-", "data": 0});
			for each (var monster:Object in level_object.monsters)
				o.push({"label": monster["name"], "data": monster["id"]});
			
			o.sortOn("data", Array.NUMERIC);
			return o;
		}
		
		/**
		 * Creates an array for ComboBoxes from the map paths.
		 * @return List Array of Map Paths
		 */
		public function getPathArray():Array
		{
			var o:Array = [];
			
			o.push({"label": "NONE", "data": "0"});
			for (var path_index:String in level_object.map_paths)
				o.push({"label": "Path " + path_index, "data": path_index});
			
			o.sortOn("data", Array.NUMERIC);
			return o;
		}
		
		public function getPathPoints(path:int):Array
		{
			var o:Array = [];
			
			if (level_object.map_paths[path])
				for (var point_index:String in level_object.map_paths[path]["points"])
					o.push({"label": point_index, "data": point_index});
			else
				o.push({"label": "NONE", "data": "0"});
			
			o.sortOn("data", Array.NUMERIC);
			return o;
		}
		
		public function e_shiftWaveU(e:Event):void
		{
			var tag:Object = (e.target as PushButton).tag;
			var id:int = tag.id;
			for (var i:int = 0; i < inputs.length; i++)
			{
				if (inputs[i]["id"] == id - 1)
				{
					inputs[i]["id"] += 1;
				}
			}
			tag.id -= 1;
			_updatePositions();
		}
		
		public function e_shiftWaveD(e:Event):void
		{
			var tag:Object = (e.target as PushButton).tag;
			var id:int = tag.id;
			for (var i:int = 0; i < inputs.length; i++)
			{
				if (inputs[i]["id"] == id + 1)
				{
					inputs[i]["id"] -= 1;
				}
			}
			tag.id += 1;
			_updatePositions();
		}
		
		/**
		 * Handles Saving of the Waves editor.
		 */
		private function _save():void
		{
			sortInput();
			
			// Build Wave Array
			var data:Object = {};
			for (var i:int = 0; i < inputs.length; i++)
			{
				var wave:WavePanel = inputs[i];
				var o:Object = {};
				
				// Required, Id and Type, Delay
				o["id"] = wave.id;
				o["type"] = wave.typeBox.selectedItemLabel;
				o["wave_delay"] = int(wave.timerBox.text);
				
				// If type is monster, Path and Point
				if (o["type"] != "-DELAY-")
				{
					o["path"] = wave.pathBox.selectedItemData;
					o["point"] = wave.pointBox.selectedItemData;
					
					// If Selected, Start in Reverse
					if (wave.reverseBox.selected)
						o["reversed"] = wave.reverseBox.selected;
				}
				else
					o["type"] = "";
				
				// If Selected, End of Wave
				if (wave.waveEndBox.selected)
					o["end_of_wave"] = wave.waveEndBox.selected;
				
				data[o["id"]] = o;
			}
			
			level_object.waves = data;
			
			// Update Positions
			_updatePositions();
		}
	}

}
import com.bit101.components.CheckBox;
import com.bit101.components.ComboBox;
import com.bit101.components.InputText;
import com.bit101.components.PushButton;
import editors.editorWave;
import flash.display.Sprite;
import flash.events.Event;

internal class WavePanel extends Sprite
{
	public var id:int = 0;
	public var wave:Object;
	public var editor:editorWave;
	
	public var shiftUButton:PushButton;
	public var shiftDButton:PushButton;
	
	public var typeBox:ComboBox;
	public var pathBox:ComboBox;
	public var pointBox:ComboBox;
	public var timerBox:InputText;
	public var reverseBox:CheckBox;
	public var waveEndBox:CheckBox;
	public var delButton:PushButton;
	
	public function WavePanel(editor:editorWave, wave:Object)
	{
		this.wave = wave;
		this.editor = editor;
		id = (wave ? wave["id"] : 0);
		
		// Shift Order Buttons
		shiftUButton = new PushButton(this, 0, 0, "U", editor.e_shiftWaveU);
		shiftUButton.setSize(20, 20);
		
		shiftDButton = new PushButton(this, 30, 0, "D", editor.e_shiftWaveD);
		shiftDButton.setSize(20, 20);
		
		// Monster Type
		typeBox = new ComboBox(this, 60, 0, "", editor.getMonsterTypes());
		typeBox.selectedItem = (wave && wave["type"] ? wave["type"] : "0");
		
		// Path to follow
		pathBox = new ComboBox(this, 170, 0, "", editor.getPathArray());
		pathBox.selectedItem = (wave && wave["path"] ? wave["path"] : "0");
		pathBox.addEventListener(Event.SELECT, e_pathSelectionChange);
		
		// Starting Path Point
		pointBox = new ComboBox(this, 280, 0, "");
		
		// Step End Timer
		timerBox = new InputText(this, 390, 0, wave && wave["wave_delay"] ? wave["wave_delay"] : "100");
		
		// End of Wave Flag
		reverseBox = new CheckBox(this, 500, 0, "Start in Reverse");
		reverseBox.selected = (wave && wave["reversed"]);
		
		// End of Wave Flag
		waveEndBox = new CheckBox(this, 610, 0, "End of Wave");
		waveEndBox.selected = (wave && wave["end_of_wave"]);
		
		// Delete Button
		delButton = new PushButton(this, 720, 0, "Delete", editor.e_deleteButton);
		
		shiftUButton.tag = shiftDButton.tag = delButton.tag = this;
		
		// Update Path Points
		updatePathPoints();
	}
	
	private function e_pathSelectionChange(e:Event):void
	{
		updatePathPoints();
	}
	
	public function updatePathPoints():void
	{
		pointBox.items = editor.getPathPoints(pathBox.selectedIndex);
		pointBox.selectedItem = (wave && wave["point"] ? wave["point"] : "0");
	}
	
	public function updateEnabled():void
	{
		shiftUButton.enabled = (id > 1);
		shiftDButton.enabled = (id < editor.inputs.length);
	}
}