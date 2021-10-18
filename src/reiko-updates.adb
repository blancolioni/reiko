with Reiko.Control;

package body Reiko.Updates is

   ----------------
   -- Add_Update --
   ----------------

   procedure Add_Update
     (Update       : Root_Update_Type'Class;
      Update_Delay : Reiko_Duration)
   is
   begin
      Add_Update_At (Update, Reiko.Control.Clock + Update_Delay);
   end Add_Update;

   -------------------
   -- Add_Update_At --
   -------------------

   procedure Add_Update_At
     (Update : Root_Update_Type'Class; Update_At : Reiko_Time)
   is
   begin
      Reiko.Control.Add_Update (Update, Update_At);
   end Add_Update_At;

end Reiko.Updates;
