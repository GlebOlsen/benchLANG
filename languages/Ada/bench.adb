with Ada.Text_IO, Ada.Real_Time, Ada.Command_Line;
use Ada.Text_IO, Ada.Real_Time;

procedure Bench is

   -- Constants
   PRIMES_LIMIT : constant := 20_000_000;
   FIBONACCI_N : Integer;
   SENTENCE : constant String := "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

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
   pragma No_Inline(Fib);

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

   procedure Benchmark_Strings is
      Start_Time, End_Time : Time;
      Match_Count : Long_Long_Integer := 0;
      Reverse_Count : Long_Long_Integer := 0;
      Word_Start : Integer := 1;
      Word_Count : Integer := 0;
      Words : array (1..20) of Integer := (others => 1);
      Word_Lens : array (1..20) of Integer := (others => 0);
      Current_Chars : array (1..100) of Character;
      Char_Idx : Integer;
      Temp_Char : Character;
   begin
      Put_Line("Running String Benchmark...");
      Start_Time := Clock;
      
      -- Split sentence into words (store positions and lengths)
      for I in SENTENCE'Range loop
         if SENTENCE(I) = ' ' then
            Word_Count := Word_Count + 1;
            Words(Word_Count) := Word_Start;
            Word_Lens(Word_Count) := I - Word_Start;
            Word_Start := I + 1;
         end if;
      end loop;
      Word_Count := Word_Count + 1;
      Words(Word_Count) := Word_Start;
      Word_Lens(Word_Count) := SENTENCE'Length - Word_Start + 1;
      
      for I in 0 .. PRIMES_LIMIT - 1 loop
         declare
            Current_Word_Idx : constant Integer := (I mod Word_Count) + 1;
            Current_Word_Start : constant Integer := Words(Current_Word_Idx);
            Current_Word_Len : constant Integer := Word_Lens(Current_Word_Idx);
         begin
            -- Compare current word against all other words
            for J in 1 .. Word_Count loop
               declare
                  Match : Boolean := True;
               begin
                  if Current_Word_Len = Word_Lens(J) then
                     for K in 0 .. Current_Word_Len - 1 loop
                        if SENTENCE(Current_Word_Start + K) /= SENTENCE(Words(J) + K) then
                           Match := False;
                           exit;
                        end if;
                     end loop;
                     if Match then
                        Match_Count := Match_Count + 1;
                     end if;
                  end if;
               end;
            end loop;
         end;
         
         -- Extract and reverse each word from sentence
         Char_Idx := 0;
         for K in SENTENCE'Range loop
            if SENTENCE(K) = ' ' then
               if Char_Idx > 0 then
                  -- Reverse the word
                  for Rev in 0 .. Char_Idx - 1 loop
                     Temp_Char := Current_Chars(Char_Idx - Rev);
                  end loop;
                  Reverse_Count := Reverse_Count + Long_Long_Integer(Char_Idx);
                  Char_Idx := 0;
               end if;
            else
               Char_Idx := Char_Idx + 1;
               Current_Chars(Char_Idx) := SENTENCE(K);
            end if;
         end loop;
         -- Handle last word
         if Char_Idx > 0 then
            for Rev in 0 .. Char_Idx - 1 loop
               Temp_Char := Current_Chars(Char_Idx - Rev);
            end loop;
            Reverse_Count := Reverse_Count + Long_Long_Integer(Char_Idx);
         end if;
      end loop;
      
      End_Time := Clock;
      Put_Line("Matches:" & Match_Count'Image & ", reverse char count:" & Reverse_Count'Image & " in" &
               Duration'Image(To_Duration(End_Time - Start_Time)) & " seconds");
      New_Line;
   end Benchmark_Strings;

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
   Benchmark_Strings;
   
   Total_End := Clock;
   Put_Line("=== BENCHMARK COMPLETE ===");
   Put_Line("Total execution time:" & 
            Duration'Image(To_Duration(Total_End - Total_Start)) & " seconds");
end Bench;