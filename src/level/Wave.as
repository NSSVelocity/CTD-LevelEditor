package level
{
	
	/**
	 * Data Structure for
	 * @author Velocity (Jonathan)
	 */
	public class Wave
	{
		public var id:int;
		public var type:String; // param1 of get_Unit_Profile()
		public var lane:int; // param2 of spawn_Enemy_By_Location()
		public var node:int; // param3 of spawn_Enemy_By_Location()
		public var can_reverse:Boolean; // param4 of spawn_Enemy_By_Location()
		public var wave_delay:int; // counterTotal
		public var end_of_wave:Boolean; // Calls next_Wave() if true.
	}

}