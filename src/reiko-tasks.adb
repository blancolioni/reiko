with Ada.Calendar;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Doubly_Linked_Lists;
with Ada.Containers.Indefinite_Holders;
with Ada.Containers.Ordered_Maps;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Reiko.Tasks is

   task type Update_Task;

   package Update_Holders is
     new Ada.Containers.Indefinite_Holders
       (Root_Update_Type'Class);

   package Update_Holder_Lists is
     new Ada.Containers.Doubly_Linked_Lists
       (Update_Holders.Holder, Update_Holders."=");

   package Update_Lists is
     new Ada.Containers.Indefinite_Doubly_Linked_Lists
       (Root_Update_Type'Class);

   package Update_Maps is
     new Ada.Containers.Ordered_Maps
       (Key_Type     => Reiko_Time,
        Element_Type => Update_Lists.List,
        "="          => Update_Lists."=");

   procedure Add_Update_To_Map
     (Map       : in out Update_Maps.Map;
      Update    : Root_Update_Type'Class);

   protected Ready_Updates is
      procedure Add_Ready_Updates (List : Update_Lists.List);
      entry Next_Ready_Update (Holder : out Update_Holders.Holder);
      entry Wait_Empty;
   private
      Ready_List : Update_Holder_Lists.List;
   end Ready_Updates;

   type Update_Task_Access is access Update_Task;

   package Update_Task_Lists is
     new Ada.Containers.Doubly_Linked_Lists (Update_Task_Access);

   Update_Tasks : Update_Task_Lists.List;

   -------------------
   -- Ready_Updates --
   -------------------

   protected body Ready_Updates is

      -----------------------
      -- Add_Ready_Updates --
      -----------------------

      procedure Add_Ready_Updates (List : Update_Lists.List) is
      begin
         for Update of List loop
            Ready_List.Append (Update_Holders.To_Holder (Update));
         end loop;
      end Add_Ready_Updates;

      -----------------------
      -- Next_Ready_Update --
      -----------------------

      entry Next_Ready_Update (Holder : out Update_Holders.Holder)
        when not Ready_List.Is_Empty
      is
      begin
         Holder := Ready_List.First_Element;
         Ready_List.Delete_First;
      end Next_Ready_Update;

      ----------------
      -- Wait_Empty --
      ----------------

      entry Wait_Empty when Ready_List.Is_Empty is
      begin
         null;
      end Wait_Empty;

   end Ready_Updates;

   --------------------
   -- Update_Manager --
   --------------------

   task body Update_Manager is
      Current_Clock : Reiko_Time;
      Current_Accel : Reiko_Duration := 1.0;
      Running       : Boolean := False;
      Updates       : Update_Maps.Map;
      New_Update    : Update_Holders.Holder;
      Last_Update   : Ada.Calendar.Time := Ada.Calendar.Clock;
      Next_Update   : Ada.Calendar.Time := Ada.Calendar.Clock;

      procedure Set_Next_Update_Time;

      --------------------------
      -- Set_Next_Update_Time --
      --------------------------

      procedure Set_Next_Update_Time is
         use type Ada.Calendar.Time;
      begin
         if Updates.Is_Empty then
            Next_Update := Ada.Calendar.Clock + 60.0;
         else
            declare
               Update_Time : constant Reiko_Time := Updates.First_Key;
               Update_Delay : constant Reiko_Duration :=
                                (if Update_Time <= Current_Clock
                                 then 0.0
                                 else Reiko_Duration
                                   (Update_Time - Current_Clock));
               Delay_Duration : constant Duration :=
                                  Duration (Update_Delay / Current_Accel);
            begin
               if Running or else Delay_Duration = 0.0 then
                  Next_Update := Ada.Calendar.Clock + Delay_Duration;
               else
                  Next_Update := Ada.Calendar.Clock + 60.0;
               end if;
            end;
         end if;

      end Set_Next_Update_Time;

   begin
      select
         accept Start (Clock : in Reiko_Time) do
            Current_Clock := Clock;
         end Start;
      or
         terminate;
      end select;

      loop
         select
            accept Resume do
               Last_Update := Ada.Calendar.Clock;
               Running := True;
            end Resume;
         or
            accept Pause do
               Running := False;
            end Pause;
         or
            accept Stop;
            exit;
         or
            accept Set_Acceleration (Acceleration : in Reiko_Duration) do
               Current_Accel := Acceleration;
            end Set_Acceleration;
            Set_Next_Update_Time;
         or
            accept Get_Status (Current_Time : out Reiko_Time;
                               Paused : out Boolean;
                               Advance_Per_Second : out Reiko_Duration)
            do
               Current_Time := Current_Clock;
               Paused := not Running;
               Advance_Per_Second := Current_Accel;
            end Get_Status;
         or
            accept Add_Update (Update : in Root_Update_Type'Class)
            do
               New_Update := Update_Holders.To_Holder (Update);
            end Add_Update;

            Add_Update_To_Map (Updates, New_Update.Element);
            Set_Next_Update_Time;
         or
            accept Advance (Seconds : Reiko_Duration) do
               Current_Clock := Current_Clock + Reiko_Time (Seconds);
            end Advance;

            while not Updates.Is_Empty
              and then Updates.First_Key <= Current_Clock
            loop
               Ready_Updates.Add_Ready_Updates (Updates.First_Element);
               Updates.Delete_First;
            end loop;

            Set_Next_Update_Time;

         or
            delay until Next_Update;

            if Running then
               declare
                  use type Ada.Calendar.Time;
                  Elapsed : constant Reiko_Duration :=
                              Reiko_Duration (Next_Update - Last_Update)
                              * Current_Accel;
                  New_Clock : constant Reiko_Time :=
                                Current_Clock + Reiko_Time (Elapsed);
               begin
                  Last_Update := Next_Update;
                  Current_Clock := New_Clock;

                  Set_Next_Update_Time;
               end;
            end if;

            while not Updates.Is_Empty
              and then Updates.First_Key <= Current_Clock
            loop
               Ready_Updates.Add_Ready_Updates (Updates.First_Element);
               Updates.Delete_First;
            end loop;

         end select;
      end loop;
   end Update_Manager;

   -----------------
   -- Update_Task --
   -----------------

   task body Update_Task is
      Holder : Update_Holders.Holder;
   begin
      loop
         begin
            Ready_Updates.Next_Ready_Update (Holder);
            Holder.Constant_Reference.Execute;
         exception
            when E : others =>
               Ada.Text_IO.Put_Line
                 (Ada.Text_IO.Standard_Error,
                  "caught exception in update task "
                  & Holder.Constant_Reference.Name
                  & ": "
                  & Ada.Exceptions.Exception_Message (E));
         end;
      end loop;
   end Update_Task;

   -----------------------
   -- Add_Update_To_Map --
   -----------------------

   procedure Add_Update_To_Map
     (Map       : in out Update_Maps.Map;
      Update    : Root_Update_Type'Class)
   is
      use Update_Maps;
      Position : constant Cursor := Map.Find (Update.Time_Stamp);
   begin
      if Has_Element (Position) then
         Map (Position).Append (Update);
      else
         declare
            List : Update_Lists.List;
         begin
            List.Append (Update);
            Map.Insert (Update.Time_Stamp, List);
         end;
      end if;
   end Add_Update_To_Map;

   -------------
   -- Advance --
   -------------

   procedure Advance
     (Seconds : Reiko_Duration)
   is
   begin
      Update_Manager.Advance (Seconds);
      Ready_Updates.Wait_Empty;
   end Advance;

   -----------
   -- Start --
   -----------

   procedure Start
     (Current_Time : Reiko_Time;
      Task_Count   : Positive)
   is
   begin
      for I in 1 .. Task_Count loop
         declare
            New_Task : constant Update_Task_Access := new Update_Task;
         begin
            Update_Tasks.Append (New_Task);
         end;
      end loop;
      Update_Manager.Start (Current_Time);
   end Start;

   ----------
   -- Stop --
   ----------

   procedure Stop is
      procedure Free is
        new Ada.Unchecked_Deallocation (Update_Task, Update_Task_Access);
   begin
      Update_Manager.Stop;
      for Updater of Update_Tasks loop
         abort Updater.all;
         Free (Updater);
      end loop;
   end Stop;

end Reiko.Tasks;
