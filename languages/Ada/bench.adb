with Ada.Text_IO;              use Ada.Text_IO;
with Ada.Calendar;             use Ada.Calendar;
with Ada.Unchecked_Deallocation;
with Interfaces;               use Interfaces;

procedure Bench is
   PRIMES_LIMIT    : constant := 20_000_000;
   FIBONACCI_N     : constant := 45;
   STRING_ITER     : constant := 5_000_000;
   MANDEL_W        : constant := 4096;
   MANDEL_H        : constant := 4096;
   MANDEL_MAX_ITER : constant := 256;
   TREE_MIN_DEPTH  : constant := 4;
   TREE_MAX_DEPTH  : constant := 18;
   SENTENCE        : constant String :=
     "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

   type Tree_Node;
   type Tree_Access is access Tree_Node;
   type Tree_Node is record
      Left, Right : Tree_Access := null;
      Item        : Long_Long_Integer := 0;
   end record;

   procedure Free is new Ada.Unchecked_Deallocation (Tree_Node, Tree_Access);

   function Make_Tree (Item : Long_Long_Integer; Depth : Integer) return Tree_Access is
      N : Tree_Access := new Tree_Node;
   begin
      N.Item := Item;
      if Depth = 0 then
         N.Left := null;
         N.Right := null;
         return N;
      end if;
      N.Left  := Make_Tree (2 * Item - 1, Depth - 1);
      N.Right := Make_Tree (2 * Item, Depth - 1);
      return N;
   end Make_Tree;

   function Check_Tree (N : Tree_Access) return Long_Long_Integer is
   begin
      if N.Left = null then
         return N.Item;
      end if;
      return N.Item + Check_Tree (N.Left) - Check_Tree (N.Right);
   end Check_Tree;

   procedure Free_Tree (N : in out Tree_Access) is
   begin
      if N.Left /= null then
         Free_Tree (N.Left);
         Free_Tree (N.Right);
      end if;
      Free (N);
   end Free_Tree;

   procedure Bench_Binary_Trees is
      Start      : Time;
      Checksum   : Long_Long_Integer := 0;
      Sum        : Long_Long_Integer;
      Stretch    : Tree_Access;
      Long_Lived : Tree_Access;
      T          : Tree_Access;
      Iters      : Integer;
      D          : Integer;
   begin
      Start := Clock;

      Stretch := Make_Tree (0, TREE_MAX_DEPTH + 1);
      Checksum := Checksum + Check_Tree (Stretch);
      Free_Tree (Stretch);

      Long_Lived := Make_Tree (0, TREE_MAX_DEPTH);

      D := TREE_MIN_DEPTH;
      while D <= TREE_MAX_DEPTH loop
         Iters := 2 ** (TREE_MAX_DEPTH - D + TREE_MIN_DEPTH);
         Sum := 0;
         for I in 0 .. Iters - 1 loop
            T := Make_Tree (Long_Long_Integer (I + 1), D);
            Sum := Sum + Check_Tree (T);
            Free_Tree (T);
         end loop;
         Checksum := Checksum + Sum;
         D := D + 2;
      end loop;

      Checksum := Checksum + Check_Tree (Long_Lived);
      Free_Tree (Long_Lived);

      Put_Line ("BinaryTrees: checksum=" & Long_Long_Integer'Image (Checksum) &
                " in" & Duration'Image (Clock - Start) & " seconds");
      New_Line;
   end Bench_Binary_Trees;

   function Is_Prime(N : Integer) return Boolean is
      I : Integer := 5;
   begin
      if N <= 1 then return False; end if;
      if N <= 3 then return True; end if;
      if N mod 2 = 0 or N mod 3 = 0 then return False; end if;
      while Long_Integer(I) * Long_Integer(I) <= Long_Integer(N) loop
         if N mod I = 0 or N mod (I + 2) = 0 then return False; end if;
         I := I + 6;
      end loop;
      return True;
   end Is_Prime;

   procedure Bench_Primes is
      Start : Time;
      C     : Integer := 0;
   begin
      Start := Clock;
      for I in 2 .. PRIMES_LIMIT - 1 loop
         if Is_Prime(I) then C := C + 1; end if;
      end loop;
      Put_Line("Found" & Integer'Image(C) & " primes in" &
               Duration'Image(Clock - Start) & " seconds");
      New_Line;
   end Bench_Primes;

   function Fib(N : Integer) return Long_Long_Integer is
   begin
      if N <= 1 then return Long_Long_Integer(N); end if;
      return Fib(N - 1) + Fib(N - 2);
   end Fib;

   procedure Bench_Fib_Rec is
      Start : Time;
      R     : Long_Long_Integer;
   begin
      Start := Clock;
      R := Fib(FIBONACCI_N);
      Put_Line("Fibonacci(" & Integer'Image(FIBONACCI_N) & ") =" &
               Long_Long_Integer'Image(R) & " in" & Duration'Image(Clock - Start) & " seconds");
      New_Line;
   end Bench_Fib_Rec;

   procedure Bench_Strings is
      type String_Access is access String;
      type Word_Array is array (Natural range <>) of String_Access;

      Words  : Word_Array (0 .. 31);
      WCount : Integer := 0;
      Start  : Time;
      Total  : Unsigned_64 := 0;
      Count  : Unsigned_64;
   begin
      Start := Clock;

      declare
         Pos : Integer := SENTENCE'First;
         StartIdx : Integer;
      begin
         while Pos <= SENTENCE'Last loop
            StartIdx := Pos;
            while Pos <= SENTENCE'Last and then SENTENCE(Pos) /= ' ' loop
               Pos := Pos + 1;
            end loop;
            Words(WCount) := new String'(SENTENCE(StartIdx .. Pos - 1));
            WCount := WCount + 1;
            while Pos <= SENTENCE'Last and then SENTENCE(Pos) = ' ' loop
               Pos := Pos + 1;
            end loop;
         end loop;
      end;

      for I in 0 .. STRING_ITER - 1 loop
         for K in 0 .. WCount - 1 loop
            Count := 0;
            for J in 0 .. WCount - 1 loop
               if Words(K).all = Words(J).all then Count := Count + 1; end if;
            end loop;
            Total := Total + Count;
         end loop;
      end loop;

      Put_Line("Strings: total=" & Unsigned_64'Image(Total) &
               " in" & Duration'Image(Clock - Start) & " seconds");
      New_Line;
   end Bench_Strings;

   procedure Bench_Mandelbrot is
      Start : Time;
      Checksum : Long_Long_Integer := 0;
      Cx, Cy, Zx, Zy, Nx : Long_Float;
      Iter : Integer;
   begin
      Start := Clock;
      for Py in 0 .. MANDEL_H - 1 loop
         Cy := (Long_Float(Py) / Long_Float(MANDEL_H)) * 3.0 - 1.5;
         for Px in 0 .. MANDEL_W - 1 loop
            Cx := (Long_Float(Px) / Long_Float(MANDEL_W)) * 3.0 - 2.0;
            Zx := 0.0;
            Zy := 0.0;
            Iter := 0;
            while Iter < MANDEL_MAX_ITER and then Zx * Zx + Zy * Zy <= 4.0 loop
               Nx := Zx * Zx - Zy * Zy + Cx;
               Zy := 2.0 * Zx * Zy + Cy;
               Zx := Nx;
               Iter := Iter + 1;
            end loop;
            Checksum := Checksum + Long_Long_Integer(Iter);
         end loop;
      end loop;
      Put_Line("Mandelbrot: checksum=" & Long_Long_Integer'Image(Checksum) &
               " in" & Duration'Image(Clock - Start) & " seconds");
      New_Line;
   end Bench_Mandelbrot;

   Total_Start : Time;
begin
   Put_Line("=== PROGRAMMING LANGUAGE BENCHMARK ===");
   New_Line;
   Total_Start := Clock;
   Bench_Primes;
   Bench_Fib_Rec;
   Bench_Strings;
   Bench_Mandelbrot;
   Bench_Binary_Trees;
   Put_Line("=== BENCHMARK COMPLETE ===");
   Put_Line("Total execution time:" & Duration'Image(Clock - Total_Start) & " seconds");
end Bench;
