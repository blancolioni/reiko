package Reiko is

   type Reiko_Duration is new Long_Float;
   type Reiko_Time is new Long_Float;

   function "+" (Left : Reiko_Time;
                 Right : Reiko_Duration)
                 return Reiko_Time;

   type Root_Update_Type is abstract tagged private;

   function Name (Update : Root_Update_Type) return String is abstract;

   procedure Execute (Update : Root_Update_Type) is abstract;

private

   type Root_Update_Type is abstract tagged
      record
         Time_Stamp : Reiko_Time;
      end record;

   pragma Import (Intrinsic, "+");

end Reiko;
