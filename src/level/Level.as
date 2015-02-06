package level
{
	
	/**
	 * Data structure for CTD levels.
	 * @author Velocity (Jonathan)
	 */
	public class Level
	{
		public var map_bounds:Object = { "width": 800, "height": 480 };
		public var map_paths:Object = {};
		public var map_spots:Object = {};
		
		public var monsters:Object = [];
		
		public var loot:Object = {};
		
		public var waves:Object = [];
		
		public function Level() 
		{
			
			// Loot Structure
			loot = { };
			loot["common"] = { "chance": 0.8, "items": [] };
			loot["monsters"] = [];
			loot["special"] = { "loot_chance_reset": 0,  "loot_chance_increase": 0.05, "items": [] };
			
		}
		/**
		 * Loads a level from the provided JSON string.
		 * @param	input Level JSON.
		 */
		public function fromJSON(input:String):void
		{
			var data:Object = JSON.parse(input);
			
			// Load Paths
			map_paths = data["paths"];

			// Load Spots
			map_spots = data["spots"];
			
			// Load Monsters
			monsters = data["monsters"];
			
			// Load Loot
			loot = data["loot"];
			
			// Load Waves
			waves = data["waves"];
			
			trace("Loaded!");
		}
		
		public function toJSON():String
		{
			var o:Object = { };
			
			o["bounds"] = map_bounds;
			o["paths"] = map_paths;
			o["spots"] = map_spots;
			o["monsters"] = monsters;
			o["loot"] = loot;
			o["waves"] = waves;
			
			return JSON.stringify(o);
		}
	
	}

}