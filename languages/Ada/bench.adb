with Ada.Text_IO, Ada.Real_Time, Ada.Command_Line;
use Ada.Text_IO, Ada.Real_Time;

procedure Bench is

   -- Constants
   PRIMES_LIMIT : constant := 20_000_000;
   FIBONACCI_N : Integer;

   function Is_Prime(N : Integer) return Boolean is
      I : Integer := 5;
   begin
      if N <= 1 then return False; end if;
      if N <= 3 then return True; end if;
      if N mod 2 = 0 or N mod 3 = 0 then return False; end if;
      
      while I * I <= N loop
         if N mod I = 0 or N mod (I + 2) = 0 then
            return False;
         end if;
         I := I + 6;
      end loop;
      return True;
   end Is_Prime;

   procedure Benchmark_Primes is
      Start_Time, End_Time : Time;
      Count : Integer := 0;
   begin
      Put_Line("Running Prime Numbers Benchmark (up to" & PRIMES_LIMIT'Image & ")...");
      Start_Time := Clock;
      
      for I in 2 .. PRIMES_LIMIT - 1 loop
         if Is_Prime(I) then
            Count := Count + 1;
         end if;
      end loop;
      
      End_Time := Clock;
      Put_Line("Found" & Count'Image & " primes in" & 
               Duration'Image(To_Duration(End_Time - Start_Time)) & " seconds");
      New_Line;
   end Benchmark_Primes;

   function Fib(N : Integer) return Integer is
   begin
      if N <= 1 then
         return N;
      else
         return Fib(N - 1) + Fib(N - 2);
      end if;
   end Fib;

   procedure Benchmark_Fibonacci is
      Start_Time, End_Time : Time;
      Result : Integer;
   begin
      Put_Line("Running Fibonacci Benchmark (n=" & FIBONACCI_N'Image & ", recursive)...");
      Start_Time := Clock;
      
      Result := Fib(FIBONACCI_N);
      
      End_Time := Clock;
      Put_Line("Fibonacci(" & FIBONACCI_N'Image & ") =" & Result'Image & " in" &
               Duration'Image(To_Duration(End_Time - Start_Time)) & " seconds");
      New_Line;
   end Benchmark_Fibonacci;

   Total_Start, Total_End : Time;

begin
   -- Prevent compile-time optimization of fibonacci
   if Ada.Command_Line.Argument_Count > 0 then
      FIBONACCI_N := Integer'Value(Ada.Command_Line.Argument(1));
   else
      FIBONACCI_N := 45;
   end if;
   
   Put_Line("=== PROGRAMMING LANGUAGE BENCHMARK ===");
   New_Line;
   
   Total_Start := Clock;
   
   Benchmark_Primes;
   Benchmark_Fibonacci;
   
   Total_End := Clock;
   Put_Line("=== BENCHMARK COMPLETE ===");
   Put_Line("Total execution time:" & 
            Duration'Image(To_Duration(Total_End - Total_Start)) & " seconds");
end Bench;