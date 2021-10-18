package Reiko.Updates is

   procedure Add_Update
     (Update       : Root_Update_Type'Class;
      Update_Delay : Reiko_Duration);

   procedure Add_Update_At
     (Update    : Root_Update_Type'Class;
      Update_At : Reiko_Time);

end Reiko.Updates;
