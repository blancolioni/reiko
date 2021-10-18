package Reiko.Paths is

   Config_Path : constant String :=
     "/home/fraser/git/reiko/config";

   function Config_File
     (File_Path : String)
     return String
   is (Config_Path & "/" & File_Path);

end Reiko.Paths;
