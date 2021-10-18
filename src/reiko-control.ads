package Reiko.Control is

   procedure Start
     (Current_Time : Reiko_Time;
      Task_Count   : Positive);

   procedure Stop;

   procedure Pause;
   procedure Resume;

   procedure Set_Acceleration
     (Time_Multiplier : Reiko_Duration);

   procedure Advance
     (Seconds : Reiko_Duration);

   function Clock return Reiko_Time;
   function Current_Acceleration return Reiko_Duration;

   procedure Get_Status
     (Current_Time       : out Reiko_Time;
      Paused             : out Boolean;
      Advance_Per_Second : out Reiko_Duration);

   function Is_Active return Boolean;
   function Is_Paused return Boolean;

   procedure Add_Update
     (Update    : Root_Update_Type'Class;
      Update_At : Reiko_Time);

end Reiko.Control;
