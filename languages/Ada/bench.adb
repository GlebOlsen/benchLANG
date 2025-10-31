with Ada.Text_IO, Ada.Real_Time, Ada.Numerics.Discrete_Random, 
     Ada.Strings.Unbounded, Ada.Strings.Fixed, Ada.Containers.Generic_Array_Sort;
use Ada.Text_IO, Ada.Real_Time, Ada.Strings.Unbounded, Ada.Strings.Fixed;

procedure Bench is

   -- Constants
   PRIMES_LIMIT : constant := 20_000_000;
   FIBONACCI_N : constant := 45;
   MATRIX_SIZE : constant := 2000;
   MATRIX_RAND_MAX : constant := 100;
   SENTENCE : constant String := "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
   STRING_OPS : constant := 200_000_000;
   STRING_REDUCTION_FACTOR : constant := 100;
   SORT_SIZE : constant := 10_000_000;
   RAND_SEED : constant := 42;

   -- Types
   type Matrix_Array is array (Natural range <>) of Float;
   type Int_Array is array (Natural range <>) of Integer;
   
   -- Random number generator
   subtype Rand_Range is Integer range 0 .. Integer'Last;
   package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
   Gen : Rand_Int.Generator;

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

   procedure Benchmark_Matrix_Multiplication is
      Start_Time, End_Time : Time;
      Size : constant Natural := MATRIX_SIZE * MATRIX_SIZE;
      Matrix_A : Matrix_Array(0 .. Size - 1);
      Matrix_B : Matrix_Array(0 .. Size - 1);
      Matrix_C : Matrix_Array(0 .. Size - 1);
      N : constant Natural := MATRIX_SIZE;
   begin
      Put_Line("Running Matrix Multiplication Benchmark (" & 
               MATRIX_SIZE'Image & "x" & MATRIX_SIZE'Image & ")...");
      Start_Time := Clock;
      
      -- Initialize matrices
      Rand_Int.Reset(Gen, RAND_SEED);
      for I in Matrix_A'Range loop
         Matrix_A(I) := Float(Rand_Int.Random(Gen) mod MATRIX_RAND_MAX);
         Matrix_B(I) := Float(Rand_Int.Random(Gen) mod MATRIX_RAND_MAX);
         Matrix_C(I) := 0.0;
      end loop;
      
      -- Matrix multiplication (i-k-j order for cache efficiency)
      for I in 0 .. N - 1 loop
         for K in 0 .. N - 1 loop
            declare
               AIK : constant Float := Matrix_A(I * N + K);
            begin
               for J in 0 .. N - 1 loop
                  Matrix_C(I * N + J) := Matrix_C(I * N + J) + AIK * Matrix_B(K * N + J);
               end loop;
            end;
         end loop;
      end loop;
      
      End_Time := Clock;
      Put_Line("Matrix multiplication completed in" &
               Duration'Image(To_Duration(End_Time - Start_Time)) & " seconds");
      New_Line;
   end Benchmark_Matrix_Multiplication;

   procedure Benchmark_Sorting is
      Start_Time, End_Time : Time;
      Sort_Arr : Int_Array(0 .. SORT_SIZE - 1);
      
      procedure Sort is new Ada.Containers.Generic_Array_Sort
        (Index_Type   => Natural,
         Element_Type => Integer,
         Array_Type   => Int_Array,
         "<"          => "<");
   begin
      Put_Line("Running Sorting Benchmark (" & SORT_SIZE'Image & " elements)...");
      Start_Time := Clock;
      
      Rand_Int.Reset(Gen, RAND_SEED);
      for I in Sort_Arr'Range loop
         Sort_Arr(I) := Rand_Int.Random(Gen);
      end loop;
      
      Sort(Sort_Arr);
      
      End_Time := Clock;
      Put_Line("Sorting completed in" &
               Duration'Image(To_Duration(End_Time - Start_Time)) & " seconds");
      New_Line;
   end Benchmark_Sorting;

   procedure Benchmark_String_Operations is
      Start_Time, End_Time : Time;
      Repeats : constant Natural := STRING_OPS / STRING_REDUCTION_FACTOR;
      Hay : Unbounded_String;
      Total : Natural := 0;
      
      type String_Access is access String;
      type String_Array is array (Natural range <>) of String_Access;
      
      function Split_String(S : String; Delimiter : Character) return String_Array is
         Count : Natural := 0;
         Start : Natural := S'First;
      begin
         -- Count words
         for I in S'Range loop
            if S(I) = Delimiter or I = S'Last then
               Count := Count + 1;
            end if;
         end loop;
         
         declare
            Words : String_Array(0 .. Count - 1);
            Word_Idx : Natural := 0;
         begin
            Start := S'First;
            for I in S'Range loop
               if S(I) = Delimiter then
                  if I > Start then
                     Words(Word_Idx) := new String'(S(Start .. I - 1));
                     Word_Idx := Word_Idx + 1;
                  end if;
                  Start := I + 1;
               elsif I = S'Last then
                  Words(Word_Idx) := new String'(S(Start .. I));
                  Word_Idx := Word_Idx + 1;
               end if;
            end loop;
            return Words;
         end;
      end Split_String;
      
      function Count_Occurrences(Source, Pattern : String) return Natural is
         Count : Natural := 0;
         Pos : Natural := Source'First;
      begin
         while Pos <= Source'Last - Pattern'Length + 1 loop
            if Source(Pos .. Pos + Pattern'Length - 1) = Pattern then
               Count := Count + 1;
            end if;
            Pos := Pos + 1;
         end loop;
         return Count;
      end Count_Occurrences;
      
   begin
      Put_Line("Running String Operations Benchmark (" & STRING_OPS'Image & " operations)...");
      Start_Time := Clock;
      
      -- Build large string
      for I in 1 .. Repeats loop
         Append(Hay, SENTENCE);
      end loop;
      
      -- Dynamic word extraction and searching (matching Java/Pascal behavior)
      declare
         Words : constant String_Array := Split_String(SENTENCE, ' ');
         Hay_Str : constant String := To_String(Hay);
         Found : Natural;
      begin
         for Word of Words loop
            Found := Count_Occurrences(Hay_Str, Word.all);
            Total := Total + Found;
         end loop;
      end;
      
      End_Time := Clock;
      Put_Line("String operations completed in" &
               Duration'Image(To_Duration(End_Time - Start_Time)) & 
               " seconds (found" & Total'Image & " word instances)");
      New_Line;
   end Benchmark_String_Operations;

   Total_Start, Total_End : Time;

begin
   Put_Line("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK (Ada) ===");
   New_Line;
   
   Total_Start := Clock;
   
   Benchmark_Primes;
   Benchmark_Fibonacci;
   Benchmark_Matrix_Multiplication;
   Benchmark_Sorting;
   Benchmark_String_Operations;
   
   Total_End := Clock;
   Put_Line("=== BENCHMARK COMPLETE ===");
   Put_Line("Total execution time:" & 
            Duration'Image(To_Duration(Total_End - Total_Start)) & " seconds");
end Bench;