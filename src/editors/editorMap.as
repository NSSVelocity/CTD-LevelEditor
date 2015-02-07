package editors
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.ScrollPane;
	import com.bit101.components.Window;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import level.Level;
	
	/**
	 * Editor for Map Objects (Path, Towers, Camps)
	 * @author Velocity (Jonathan)
	 */
	public class editorMap extends EditorWindow
	{
		// Path Colors
		public static var path_colors:Array = [0x1C771E, 0xF42C2C, 0x4A89EF, 0x04EA27, 0x969601, 0xC541E0, 0x41DBE0, 0xD3660C, 0x3D4DE2, 0x98E23D];
		
		public var MAP_STAGE_OFFSET_X:int = 0;
		public var MAP_STAGE_OFFSET_Y:int = 0;
		
		// Hold Shift/Alt/Ctrl Status
		private var _keys:Object = {};
		
		// Active Path
		private var _activePath:String = "1";
		
		// Active Group
		private var _activeTab:int = 1;
		
		// Active pin
		private var _dragPin:*;
		private var _tagReference:Object;
		
		// Level Save
		public var level_object:Level;
		
		public var map_win:Window;
		public var map_pan:ScrollPane;
		public var editor_menu_pan:Panel;
		public var editor_menu_options_pan:Panel;
		public var editor_win:Window;
		public var editor_pan:ScrollPane;
		
		private var map_bounds_mask:Sprite;
		private var map_paths:Sprite;
		private var file_button:PushButton;
		private var file_selector:FileReference;
		
		private var map_move_left:PushButton;
		private var map_move_right:PushButton;
		private var map_move_up:PushButton;
		private var map_move_down:PushButton;
		private var map_widthBox:InputText;
		private var map_heightBox:InputText;
		private var map_xBox:InputText;
		private var map_yBox:InputText;
		
		private var tab_paths:PushButton;
		private var tab_towers:PushButton;
		private var tab_spots:PushButton;
		
		//Paths
		private var map_path_list:ComboBox;
		private var map_path_add:PushButton;
		private var map_path_remove:PushButton;
		private var map_path_lock:CheckBox;
		private var map_point_add:PushButton;
		private var map_point_inputs:Array;
		
		/**
		 * Constructor for Map editor.
		 * @param	_level_object Save object that holds the level structure.
		 */
		public function editorMap(_level_object:Level)
		{
			this.level_object = _level_object;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Key Listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN, e_onKeyBoardDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, e_onKeyBoardUp);
			
			///- Create Map Window
			map_win = new Window(this, 0, 0, "Map View");
			map_pan = new ScrollPane(map_win);
			map_pan.autoHideScrollBar = true;
			map_pan.addEventListener(MouseEvent.RIGHT_CLICK, e_rightClickPointAdd);
			
			var STAGE_OFFSET:Point = map_pan.localToGlobal(new Point());
			MAP_STAGE_OFFSET_X = STAGE_OFFSET.x;
			MAP_STAGE_OFFSET_Y = STAGE_OFFSET.y;
			
			map_bounds_mask = new Sprite();
			map_paths = new Sprite();
			map_paths.x = 50;
			map_paths.y = 50;
			map_pan.addChildAt(new Sprite(), 0); // Map Index
			map_pan.addChildAt(map_bounds_mask, 1); // Bounds Index
			map_pan.addChildAt(map_paths, 2); // Paths Index
			
			///- Create Editor Menu
			editor_menu_pan = new Panel(this);
			editor_menu_pan.setSize(200, 105);
			
			// Create Map Loading Buttons
			file_button = new PushButton(editor_menu_pan, 5, 5, "Load Map Image", e_loadMapButton);
			file_button.setSize(90, 20);
			
			// Map Move Buttons
			map_move_left = new PushButton(editor_menu_pan, 100, 5, "L", e_mapMove);
			map_move_left.setSize(20, 20);
			map_move_left.tag = "L";
			map_move_right = new PushButton(editor_menu_pan, 125, 5, "R", e_mapMove);
			map_move_right.setSize(20, 20);
			map_move_right.tag = "R";
			map_move_up = new PushButton(editor_menu_pan, 150, 5, "U", e_mapMove);
			map_move_up.setSize(20, 20);
			map_move_up.tag = "U";
			map_move_down = new PushButton(editor_menu_pan, 175, 5, "D", e_mapMove);
			map_move_down.setSize(20, 20);
			map_move_down.tag = "D";
			
			// Map Bounds Boxes
			map_xBox = new InputText(editor_menu_pan, 5, 30, "0", e_mapOffsetChange);
			map_xBox.setSize(80, 20);
			
			new Label(editor_menu_pan, 96, 30, "x");
			
			map_yBox = new InputText(editor_menu_pan, 115, 30, "0", e_mapOffsetChange);
			map_yBox.setSize(80, 20);
			
			// Map Bounds Boxes
			map_widthBox = new InputText(editor_menu_pan, 5, 55, level_object.map_bounds["width"].toString(), e_boundsChange);
			map_widthBox.setSize(80, 20);
			
			new Label(editor_menu_pan, 96, 55, "x");
			
			map_heightBox = new InputText(editor_menu_pan, 115, 55, level_object.map_bounds["height"].toString(), e_boundsChange);
			map_heightBox.setSize(80, 20);
			
			// Tab Buttons
			tab_paths = new PushButton(editor_menu_pan, 5, 80, "Paths", e_tabSelection);
			tab_paths.setSize(60, 20);
			tab_paths.tag = 1;
			
			tab_towers = new PushButton(editor_menu_pan, 70, 80, "Towers", e_tabSelection);
			tab_towers.setSize(60, 20);
			tab_towers.tag = 2;
			
			tab_spots = new PushButton(editor_menu_pan, 135, 80, "Spots", e_tabSelection);
			tab_spots.setSize(60, 20);
			tab_spots.tag = 3;
			
			///- Selection Options
			editor_menu_options_pan = new Panel(this);
			editor_menu_options_pan.setSize(200, 70);
			
			_displayObjectGroupOptions();
			
			// Create Editor Window
			editor_win = new Window(this, 0, 0, "");
			editor_win.setSize(200, 100);
			editor_pan = new ScrollPane(editor_win);
			editor_pan.autoHideScrollBar = true;
			editor_pan.useHorizontalScrollBar = false;
			
			// Draw Elements
			_updateBounds(level_object.map_bounds["width"], level_object.map_bounds["height"]);
			
			if (Editor.map_image)
				e_displayMap();
			
			_updatePathPoints();
		}
		
		private function _displayObjectGroupOptions():void
		{
			// Clear
			editor_menu_options_pan.removeChildren(0);
			
			// Paths
			if (_activeTab == 1)
			{
				map_path_list = new ComboBox(editor_menu_options_pan, 5, 5, "", _getPathArray());
				map_path_list.selectedItem = "1";
				map_path_list.setSize(190, 20);
				map_path_list.addEventListener(Event.SELECT, e_pathSelectionChange);
				
				map_path_add = new PushButton(editor_menu_options_pan, 5, 30, "Add Path", e_pathAdd);
				map_path_add.setSize(93, 20);
				
				map_path_remove = new PushButton(editor_menu_options_pan, 103, 30, "Remove Path", e_pathRemove);
				map_path_remove.setSize(92, 20);
				
				map_path_lock = new CheckBox(editor_menu_options_pan, 5, 55, "Lock Path", e_togglePathLock);
			}
		}
		
		private function e_togglePathLock(e:Event):void
		{
			level_object.map_paths[_activePath]["path_locked"] = !level_object.map_paths[_activePath]["path_locked"];
			_updatePathPoints();
		}
		
		/**
		 * Cleans up class before deletion.
		 */
		override public function destroy():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, e_onKeyBoardDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, e_onKeyBoardUp);
		}
		
		/**
		 * Resizes Editor window based on provided sizes.
		 * @param	width
		 * @param	height
		 */
		override public function resize(width:Number, height:Number):void
		{
			// Update Map
			map_win.setSize(width - 205, height);
			map_pan.setSize(map_win.width, map_win.height - 20);
			map_pan.update();
			
			// Update Options
			editor_menu_options_pan.move(width - 200, 110);
			
			// Update Node Editor
			editor_menu_pan.move(width - 200, 0);
			editor_win.move(width - 200, 185);
			editor_win.setSize(editor_win.width, height - 185);
			editor_pan.setSize(editor_win.width, editor_win.height - 20);
		}
		
		/**
		 * Handle Keyboard Down Event
		 */
		private function e_onKeyBoardDown(e:KeyboardEvent):void
		{
			_keys["shift"] = e.shiftKey;
			_keys["alt"] = e.altKey;
			_keys["ctrl"] = e.ctrlKey;
			
			switch (e.keyCode)
			{
				case Keyboard.W: 
					_shiftMap("U");
					break;
				
				case Keyboard.S: 
					_shiftMap("D");
					break;
				
				case Keyboard.A: 
					_shiftMap("L");
					break;
				
				case Keyboard.D: 
					_shiftMap("R");
					break;
			}
		}
		
		/**
		 * Handle Keyboard Up Event
		 */
		private function e_onKeyBoardUp(e:KeyboardEvent):void
		{
			_keys["shift"] = e.shiftKey;
			_keys["alt"] = e.altKey;
			_keys["ctrl"] = e.ctrlKey;
		}
		
		/**
		 * Handles context based right-click events on the map editor.
		 */
		private function e_rightClickPointAdd(e:MouseEvent):void
		{
			// Path Point Add
			if (_activeTab == 1)
			{
				if (level_object.map_paths[_activePath]["path_locked"])
					return;
					
				var ni:String = _path_reorderPoints();
				_pathAddNewPoint(_activePath, ni, e.stageX - MAP_STAGE_OFFSET_X - 50, e.stageY - MAP_STAGE_OFFSET_Y - 50);
				_updatePathPoints();
			}
		}
		
		/**
		 * Begin Map Pin drag.
		 */
		private function e_pathPointDragStart(e:MouseEvent):void
		{
			// Set Pin
			_dragPin = (e.target as MapPinPath);
			_dragPin.startDrag(true);
			map_pan.setChildIndex(_dragPin, map_pan.content.numChildren - 1);
			_tagReference = _getInputReference(_dragPin);
			
			// Add Events
			stage.addEventListener(MouseEvent.MOUSE_MOVE, e_pathPointDragMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, e_pathPointDragEnd);
		}
		
		/**
		 * End Map Pin drag.
		 */
		private function e_pathPointDragEnd(e:MouseEvent):void
		{
			_dragPin.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, e_pathPointDragMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, e_pathPointDragEnd);
		}
		
		/**
		 * Mouse movement during a Map Pin Drag.
		 */
		private function e_pathPointDragMove(e:MouseEvent):void
		{
			var point:Object = level_object.map_paths[_dragPin.path]["points"][_dragPin.pos];
			
			point["x"] = _dragPin.x;
			point["y"] = _dragPin.y;
			
			if (_tagReference)
			{
				(_tagReference["iX"] as InputText).text = _dragPin.x.toString();
				(_tagReference["iY"] as InputText).text = _dragPin.y.toString();
			}
			
			_drawPaths();
			map_pan.update();
		}
		
		/**
		 * Handles the 4 move map buttons.
		 */
		private function e_mapMove(e:Event):void
		{
			var dir:String = (e.target as PushButton).tag;
			
			if (!Editor.map_image)
				return;
			
			_shiftMap(dir);
		}
		
		/**
		 * Begins the Map Load Image event tree.
		 */
		private function e_loadMapButton(e:Event):void
		{
			file_selector = new FileReference();
			
			var imageFileTypes:FileFilter = new FileFilter("Images (*.jpg, *.png)", "*.jpg;*.png");
			
			file_selector.browse([imageFileTypes]);
			file_selector.addEventListener(Event.SELECT, e_selectFile);
		}
		
		private function e_selectFile(e:Event):void
		{
			file_selector.addEventListener(Event.COMPLETE, e_loadFile);
			file_selector.load();
		}
		
		private function e_loadFile(e:Event):void
		{
			Editor.map_image = new Loader();
			Editor.map_image.contentLoaderInfo.addEventListener(Event.COMPLETE, e_displayMap);
			Editor.map_image.loadBytes(file_selector.data);
		}
		
		private function e_displayMap(e:Event = null):void
		{
			// Remove Existing Map Image if exist.
			map_pan.removeChildAt(0);
			
			Editor.map_image.x = 50;
			Editor.map_image.y = 50;
			map_pan.addChildAt(Editor.map_image, 0);
			
			_shiftMap(null);
			
			map_pan.update();
		}
		
		/**
		 * Handles the Map Image x/y position Text change event.
		 */
		private function e_mapOffsetChange(e:Event):void
		{
			if (Editor.map_image)
			{
				Editor.map_image.x = int(map_xBox.text) + 50;
				Editor.map_image.y = int(map_yBox.text) + 50;
			}
		}
		
		/**
		 * Handles the Map Bounds Text change event.
		 */
		private function e_boundsChange(e:Event):void
		{
			var nW:Number = Number(map_widthBox.text);
			var nH:Number = Number(map_heightBox.text);
			
			if (nW < 5)
				nW = 5;
			if (nH < 5)
				nH = 5;
			_updateBounds(nW, nH);
		}
		
		/**
		 * Handles the 3 Group Tab buttons.
		 */
		private function e_tabSelection(e:Event):void
		{
			_activeTab = (e.target as PushButton).tag;
			_displayObjectGroupOptions();
		}
		
		/**
		 * Update Event Handler to Path selection.
		 */
		private function e_pathSelectionChange(e:Event):void
		{
			var new_path:Object = map_path_list.selectedItem;
			
			// Update Active Path
			_activePath = new_path["data"];
			
			map_path_lock.selected = level_object.map_paths[_activePath]["path_locked"];
			_updatePathPoints();
		}
		
		/**
		 * Handles the X and Y point input events.
		 */
		private function e_pointTextUpdate(e:Event):void
		{
			var tag:Object = (e.target as InputText).tag;
			
			var point:Object = level_object.map_paths[_activePath]["points"][tag["pos"]];
			
			point["x"] = Number((tag["iX"] as InputText).text);
			point["y"] = Number((tag["iY"] as InputText).text);
			
			_updatePathPoints();
		}
		
		/**
		 * Handles the point deletion event.
		 */
		private function e_pointDeletion(e:Event):void
		{
			var tag:Object = (e.target as PushButton).tag;
			delete level_object.map_paths[_activePath]["points"][tag["pos"]];
			
			_path_reorderPoints();
			_updatePathPoints();
		}
		
		/**
		 * Adds a new path point to the current path.
		 */
		private function e_pointAddNew(e:Event):void
		{
			var ni:String = _path_reorderPoints();
			_pathAddNewPoint(_activePath, ni);
			_updatePathPoints();
		}
		
		/**
		 * Adds a new path for the level.
		 */
		private function e_pathAdd(e:Event):void
		{
			var ni:String = _path_reorderPaths();
			
			// Create New Path
			level_object.map_paths[ni] = {"id": ni, "points": {}};
			//_pathAddNewPoint(ni, "1");
			//_pathAddNewPoint(ni, "2");
			
			_activePath = ni;
			map_path_list.items = _getPathArray();
			map_path_list.selectedItem = ni;
			
			_updatePathPoints();
		}
		
		/**
		 * Removes the active path.
		 */
		private function e_pathRemove(e:Event):void
		{
			
			delete level_object.map_paths[_activePath];
			
			_activePath = "1";
			_path_reorderPaths();
			_updatePathPoints();
			
			// Update Active Path
			map_path_list.items = _getPathArray();
			map_path_list.selectedItem = "1";
		}
		
		/**
		 * Shift the map image based on input direction.
		 * @param	dir Direction to shift map.
		 */
		private function _shiftMap(dir:String):void
		{
			if (!Editor.map_image)
				return;
			
			switch (dir)
			{
				case "U": 
					Editor.map_image.y -= (_keys["shift"] ? 10 : 1);
					break;
				
				case "D": 
					Editor.map_image.y += (_keys["shift"] ? 10 : 1);
					break;
				
				case "L": 
					Editor.map_image.x -= (_keys["shift"] ? 10 : 1);
					break;
				
				case "R": 
					Editor.map_image.x += (_keys["shift"] ? 10 : 1);
					break;
			}
			
			map_xBox.text = (int(Editor.map_image.x) - 50).toString();
			map_yBox.text = (int(Editor.map_image.y) - 50).toString();
		}
		
		/**
		 * Returns the point inputs for the requested point.
		 * @param	path The path to look for.
		 * @param	pos The Point Position to look for.
		 * @return  The Object tag that holds the inputs for the selected inputs.
		 */
		private function _getInputReference(dragPin:*):Object
		{
			// Path Pins
			if (_activeTab == 1)
			{
				var path:String = dragPin.path;
				var pos:String = dragPin.pos;
				if (path != _activePath)
					return null;
				
				// Loop Inputs
				for each (var item:Object in map_point_inputs)
				{
					if (item["pos"] == pos)
						return item;
				}
			}
			return null;
		}
		
		/**
		 * Handles several update calls.
		 */
		private function _updatePathPoints():void
		{
			// Update Points
			_drawPointList();
			_drawPaths();
			_drawMapPins();
			
			map_pan.update();
			editor_pan.update();
		}
		
		/**
		 * Draw new map bounds.
		 * @param	width New Bounds Width
		 * @param	height New Bounds Height
		 */
		private function _updateBounds(width:Number, height:Number):void
		{
			level_object.map_bounds["width"] = width;
			level_object.map_bounds["height"] = height;
			
			map_bounds_mask.graphics.clear();
			map_bounds_mask.graphics.beginFill(0x000000, 0.5);
			
			// Bounds are split into 4 rectangles to draw. Top, Right, Bottom, Left
			map_bounds_mask.graphics.drawRect(0, 0, width + 100, 50);
			map_bounds_mask.graphics.drawRect(width + 50, 50, 50, height);
			map_bounds_mask.graphics.drawRect(0, height + 50, width + 100, 50);
			map_bounds_mask.graphics.drawRect(0, 50, 50, height);
			
			map_pan.update();
		}
		
		/**
		 * Draws all current paths, towers, and spots onto the map.
		 */
		private function _drawPaths():void
		{
			map_paths.graphics.clear();
			
			var p:Object = level_object.map_paths;
			
			// Draw Paths
			for (var index:String in p)
				if (p[index]["id"] != _activePath)
					_drawPath(index);
			
			_drawPath(_activePath);
			
			// Draw Tower/Spot Links
			p = level_object.map_spots;
			for (index in p)
			{
				var spot:Object = p[index];
				
				// Draw Tower Range
				map_paths.graphics.lineStyle(1, 0x000000);
				map_paths.graphics.beginFill(0x89D5FF, 0.25);
				map_paths.graphics.drawCircle(spot["x"], spot["y"], spot["range"]);
				map_paths.graphics.endFill();
				
				map_paths.graphics.lineStyle(3, 0x00FF00);
				map_paths.graphics.moveTo(spot["x"], spot["y"]);
				map_paths.graphics.lineTo(spot["x"] + spot["tower"]["x"], spot["y"] + spot["tower"]["y"]);
			}
		}
		
		/**
		 * Draws a path.
		 * @param	index_String Index of path to draw.
		 */
		private function _drawPath(index:String):void
		{
			var p:Object = level_object.map_paths;
			
			// Cehck Path Index Exist
			if (!p[index])
				return;
			
			var pID:String = String(p[index]["id"]);
			var path:Object = p[index]["points"];
			map_paths.graphics.lineStyle(4, path_colors[pID.charAt(pID.length - 1)], (pID == _activePath ? 1 : 0.6));
			
			// Check for atleast 2 points.
			if (!path["1"] && !path["2"])
				return;
			
			// Loop Points
			for (var point_index:String in path)
			{
				var point:Object = path[point_index];
				
				// Move to Point One
				if (point_index == "1")
					map_paths.graphics.moveTo(point["x"], point["y"]);
				else
					map_paths.graphics.lineTo(point["x"], point["y"]);
			}
		}
		
		private function _drawMapPins():void
		{
			map_pan.removeChildren(3);
			
			var pin:*;
			var o:Object;
			var index:String;
			
			// Map Path Points
			o = level_object.map_paths;
			for (index in o)
			{
				if (o[index]["path_locked"])
					continue;
				
				var path:Object = o[index]["points"];
				for (var point_index:String in path)
				{
					var point:Object = path[point_index];
					
					pin = new MapPinPath(index, point["pos"], point["x"], point["y"]);
					pin.addEventListener(MouseEvent.MOUSE_DOWN, e_pathPointDragStart);
					
					map_pan.addChild(pin);
				}
			}
			
			// Map Spots
			o = level_object.map_spots;
			if (o["1"] && !o["1"]["spots_locked"])
			{
				for (index in o)
				{
					var spot:Object = o[index];
					
					// Spot
					pin = new MapPinSpot(spot);
					//pin.addEventListener(MouseEvent.MOUSE_DOWN, e_spotPointDragStart);
					map_pan.addChild(pin);
					
					// Tower Position
					pin = new MapPinTower(spot);
					//pin.addEventListener(MouseEvent.MOUSE_DOWN, e_spotPointDragStart);
					map_pan.addChild(pin);
				}
			}
		}
		
		/**
		 * Creates the point editor window elements such as X/Y input boxes.
		 */
		private function _drawPointList():void
		{
			// Remove Old Inputs
			editor_pan.removeChildren();
			
			// Check if Path Exist
			if (!level_object.map_paths[_activePath])
				return;
			
			// Set Title
			editor_win.title = "Editing Path " + _activePath;
			
			// Add Point Button
			if (!map_point_add)
			{
				map_point_add = new PushButton(null, 5, 5, "Add Point", e_pointAddNew);
				map_point_add.setSize(183, 20);
			}
			editor_pan.addChild(map_point_add);
			
			// Path Inputs
			map_point_inputs = [];
			var nodeID:InputText;
			var nodeX:InputText;
			var nodeY:InputText;
			var nodeDelete:PushButton;
			
			// Loop Points
			var path_points:Object = level_object.map_paths[_activePath]["points"];
			for (var point_index:String in path_points)
			{
				var index:int = int(point_index);
				var point:Object = path_points[point_index];
				
				// ID
				nodeID = new InputText(editor_pan, 5, index * 30, point["pos"]);
				nodeID.setSize(30, 20);
				nodeID.maxChars = 3;
				nodeID.enabled = false;
				
				// X
				nodeX = new InputText(editor_pan, 40, index * 30, point["x"], e_pointTextUpdate);
				nodeX.setSize(60, 20);
				nodeX.maxChars = 5;
				nodeX.enabled = !level_object.map_paths[_activePath]["path_locked"];
				
				// Y
				nodeY = new InputText(editor_pan, 105, index * 30, point["y"], e_pointTextUpdate);
				nodeY.setSize(60, 20);
				nodeY.maxChars = 5;
				nodeY.enabled = !level_object.map_paths[_activePath]["path_locked"];
				
				// Delete
				nodeDelete = new PushButton(editor_pan, 168, index * 30, "D", e_pointDeletion);
				nodeDelete.setSize(20, 20);
				nodeDelete.enabled = !level_object.map_paths[_activePath]["path_locked"];
				
				var tag:Object = {"iID": nodeID, "iX": nodeX, "iY": nodeY, "iDel": nodeDelete, "pos": point["pos"]}
				nodeID.tag = nodeX.tag = nodeY.tag = nodeDelete.tag = tag;
				map_point_inputs.push(tag);
			}
		}
		
		/**
		 * Adds a new point to the selected path.
		 * @param	path Path to add point to.
		 * @param	pos Position of point in path.
		 */
		private function _pathAddNewPoint(path:String, pos:String, px:int = -999999, py:int = -999999):void
		{
			var point:Object = {"pos": pos, "x": (Number(pos) - 1) * 10, "y": 0};
			if (pos != "1" && (px == -999999 && py == -999999))
			{
				var posI:Number = Number(pos);
				var lPoint:Object = level_object.map_paths[path]["points"][posI - 1];
				if (lPoint)
				{
					point["x"] = lPoint["x"];
					point["y"] = lPoint["y"] + 20;
				}
				
			}
			else if (px != -999999 && py != -999999)
			{
				point["x"] = px;
				point["y"] = py;
			}
			level_object.map_paths[path]["points"][pos] = point;
		}
		
		/**
		 * Reorders the path points.
		 * @return The next position ID.
		 */
		private function _path_reorderPoints():String
		{
			var new_path:Object = {};
			var new_array:Array = [];
			
			var path:Object = level_object.map_paths[_activePath]["points"];
			
			// Loop points and build sortable array.
			for (var point_index:String in path)
				new_array.push(path[point_index]);
			
			new_array.sortOn("pos", Array.NUMERIC);
			
			// Build Path Object
			for (var i:int = 0; i < new_array.length; i++)
			{
				var ob:Object = new_array[i];
				ob["pos"] = (i + 1).toString();
				new_path[ob["pos"]] = ob;
			}
			
			// Set new Path
			level_object.map_paths[_activePath]["points"] = new_path;
			
			return (new_array.length + 1).toString();
		}
		
		/**
		 * Reorders the paths.
		 * @return The next position ID.
		 */
		private function _path_reorderPaths():String
		{
			var new_path:Object = {};
			var new_array:Array = [];
			
			var paths:Object = level_object.map_paths;
			
			// Loop points and build sortable array.
			for (var path_index:String in paths)
				new_array.push(paths[path_index]);
			
			new_array.sortOn("id", Array.NUMERIC);
			
			// Build Path Object
			for (var i:int = 0; i < new_array.length; i++)
			{
				var ob:Object = new_array[i];
				ob["id"] = (i + 1).toString();
				new_path[ob["id"]] = ob;
			}
			
			// Set new Path
			level_object.map_paths = new_path;
			
			return (new_array.length + 1).toString();
		}
		
		/**
		 * Creates an array for ComboBoxes from the map paths.
		 * @return List Array of Map Paths
		 */
		private function _getPathArray():Array
		{
			var o:Array = [];
			
			for (var path_index:String in level_object.map_paths)
				o.push({"label": "Path " + path_index, "data": path_index});
			
			o.sortOn("data", Array.NUMERIC);
			return o;
		}
	
	}

}

import editors.editorMap;
import flash.display.Sprite;

internal class MapPin extends Sprite
{
	public function MapPin(_x:Number, _y:Number)
	{
		x = _x;
		y = _y;
		
		buttonMode = true;
		useHandCursor = true;
		
		draw();
	}
	
	public function draw():void
	{
	
	}
	
	override public function get x():Number
	{
		return super.x - 50;
	}
	
	override public function set x(val:Number):void
	{
		super.x = val + 50;
	}
	
	override public function get y():Number
	{
		return super.y - 50;
	}
	
	override public function set y(val:Number):void
	{
		super.y = val + 50;
	}
}

internal class MapPinPath extends MapPin
{
	public var path:String;
	public var pos:String;
	
	public function MapPinPath(path:String, pos:String, _x:Number, _y:Number)
	{
		this.path = path;
		this.pos = pos;
		
		super(_x, _y);
	}
	
	public override function draw():void
	{
		this.graphics.clear();
		this.graphics.lineStyle(2, ColorUtil.brightenColor(editorMap.path_colors[String(path.charAt(path.length - 1))], 0.5));
		this.graphics.beginFill(ColorUtil.darkenColor(editorMap.path_colors[String(path.charAt(path.length - 1))], 0.7), 1);
		this.graphics.drawCircle(0, 0, 4);
		this.graphics.endFill();
	}
}

internal class MapPinSpot extends MapPin
{
	public var id:String;
	
	public function MapPinSpot(obj:Object)
	{
		this.id = obj["id"];
		super(obj["x"], obj["y"]);
	}
	
	public override function draw():void
	{
		this.graphics.clear();
		this.graphics.lineStyle(3, 0xBFD1FF);
		this.graphics.beginFill(0x001447, 1);
		this.graphics.drawCircle(0, 0, 6);
		this.graphics.endFill();
	}
}

internal class MapPinTower extends MapPin
{
	public var id:String;
	
	public function MapPinTower(obj:Object)
	{
		
		this.id = obj["id"];
		super(obj["x"] + obj["tower"]["x"], obj["y"] + obj["tower"]["y"]);
	}
	
	public override function draw():void
	{
		this.graphics.clear();
		this.graphics.lineStyle(2, 0xFFEAC1);
		this.graphics.beginFill(0x473000, 1);
		this.graphics.drawCircle(0, 0, 5);
		this.graphics.endFill();
	}
}