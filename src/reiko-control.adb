with Reiko.Tasks;

package body Reiko.Control is

   ----------------
   -- Add_Update --
   ----------------

   procedure Add_Update
     (Update    : Root_Update_Type'Class;
      Update_At : Reiko_Time)
   is
      Copy : Root_Update_Type'Class := Update;
   begin
      Copy.Time_Stamp := Update_At;
      Reiko.Tasks.Update_Manager.Add_Update (Copy);
   end Add_Update;

   -------------
   -- Advance --
   -------------

   procedure Advance
     (Seconds : Reiko_Duration)
   is
   begin
      Reiko.Tasks.Advance (Seconds);
   end Advance;

   -----------
   -- Clock --
   -----------

   function Clock return Reiko_Time is
      Current_Time       : Reiko_Time;
      Paused             : Boolean;
      Advance_Per_Second : Reiko_Duration;
   begin
      Reiko.Tasks.Update_Manager.Get_Status
        (Current_Time, Paused, Advance_Per_Second);
      return Current_Time;
   end Clock;

   --------------------------
   -- Current_Acceleration --
   --------------------------

   function Current_Acceleration return Reiko_Duration is
      Start_Time         : Reiko_Time;
      Paused             : Boolean;
      Advance_Per_Second : Reiko_Duration;
   begin
      Reiko.Tasks.Update_Manager.Get_Status
        (Start_Time, Paused, Advance_Per_Second);
      return Advance_Per_Second;
   end Current_Acceleration;

   ----------------
   -- Get_Status --
   ----------------

   procedure Get_Status
     (Current_Time       : out Reiko_Time;
      Paused             : out Boolean;
      Advance_Per_Second : out Reiko_Duration)
   is
   begin
      Reiko.Tasks.Update_Manager.Get_Status
        (Current_Time, Paused, Advance_Per_Second);
   end Get_Status;

   ---------------
   -- Is_Active --
   ---------------

   function Is_Active return Boolean is
      Start_Time         : Reiko_Time;
      Paused             : Boolean;
      Advance_Per_Second : Reiko_Duration;
   begin
      Reiko.Tasks.Update_Manager.Get_Status
        (Start_Time, Paused, Advance_Per_Second);
      return not Paused;
   end Is_Active;

   function Is_Paused return Boolean is (not Is_Active);

   -----------
   -- Pause --
   -----------

   procedure Pause is
   begin
      Reiko.Tasks.Update_Manager.Pause;
   end Pause;

   ------------
   -- Resume --
   ------------

   procedure Resume is
   begin
      Reiko.Tasks.Update_Manager.Resume;
   end Resume;

   ----------------------
   -- Set_Acceleration --
   ----------------------

   procedure Set_Acceleration
     (Time_Multiplier : Reiko_Duration)
   is
   begin
      Reiko.Tasks.Update_Manager.Set_Acceleration (Time_Multiplier);
   end Set_Acceleration;

   -----------
   -- Start --
   -----------

   procedure Start
     (Current_Time : Reiko_Time;
      Task_Count   : Positive)
   is
   begin
      Reiko.Tasks.Start (Current_Time, Task_Count);
   end Start;

   ----------
   -- Stop --
   ----------

   procedure Stop is
   begin
      Reiko.Tasks.Stop;
   end Stop;

end Reiko.Control;
