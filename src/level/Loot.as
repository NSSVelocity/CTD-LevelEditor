package level 
{
	/**
	 * Data Structure for Loot.
	 * @author Velocity (Jonathan)
	 */
	public class Loot 
	{
		public var common:Object;
		public var monsters:Array;
		public var special:Object;
		
		public function Loot() 
		{
			// Default Common Params
			common = new Object();
			common.chance = 0.8;
			common.items = [];
			
			// Default Monsters
			monsters = [];
			
			// Default Special
			special = new Object();
			special.loot_chance_increase = 0.05;
			special.loot_chance_reset = 0;
		}
		
	}
}