private package Reiko.Tasks is

   task Update_Manager is

      entry Start (Clock : Reiko_Time);
      entry Stop;
      entry Resume;
      entry Pause;
      entry Set_Acceleration (Acceleration : Reiko_Duration);
      entry Get_Status
        (Current_Time       : out Reiko_Time;
         Paused             : out Boolean;
         Advance_Per_Second : out Reiko_Duration);
      entry Add_Update
        (Update    : Root_Update_Type'Class);
      entry Advance
        (Seconds : Reiko_Duration);
   end Update_Manager;

   procedure Start
     (Current_Time : Reiko_Time;
      Task_Count   : Positive);

   procedure Stop;

   procedure Advance
     (Seconds : Reiko_Duration);

end Reiko.Tasks;
