with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar; use Ada.Calendar;

procedure Fibonacci_Benchmark is

   function Fib (N : Integer) return Integer is
   begin
      if N <= 1 then
         return N;
      else
         return Fib (N - 1) + Fib (N - 2);
      end if;
   end Fib;

   Start_Time : Time := Clock;
begin
   declare
      Result : Integer := Fib (45);
   begin
      null;
   end;
   declare
      End_Time : Time := Clock;
      Time_Taken : Duration := End_Time - Start_Time;
   begin
      Put_Line (Duration'Image (Time_Taken) & " seconds to execute");
   end;
end Fibonacci_Benchmark;
