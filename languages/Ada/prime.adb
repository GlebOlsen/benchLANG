with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar; use Ada.Calendar;

procedure Prime_Benchmark is

   function Is_Prime (N : Integer) return Boolean is
   begin
      if N <= 1 then
         return False;
      elsif N <= 3 then
         return True;
      elsif N mod 2 = 0 or else N mod 3 = 0 then
         return False;
      else
         declare
            I : Integer := 5;
         begin
            while I * I <= N loop
               if N mod I = 0 or else N mod (I + 2) = 0 then
                  return False;
               end if;
               I := I + 6;
            end loop;
         end;
         return True;
      end if;
   end Is_Prime;

   Start_Time : Time := Clock;
begin
   for I in 2 .. 9_999_999 loop
      if Is_Prime (I) then
         Put_Line (Integer'Image (I));
      end if;
   end loop;
   declare
      End_Time : Time := Clock;
      Time_Taken : Duration := End_Time - Start_Time;
   begin
      Put_Line (Duration'Image (Time_Taken) & " seconds to execute");
   end;
end Prime_Benchmark;
