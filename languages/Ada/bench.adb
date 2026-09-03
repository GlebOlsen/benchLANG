with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Real_Time;     use Ada.Real_Time;
with Ada.Strings.Fixed;
with Ada.Unchecked_Deallocation;

procedure Bench is
   PRIMES_LIMIT    : constant := 20_000_000;
   FIBONACCI_N     : constant := 45;
   STRING_ITER     : constant := 5_000_000;
   MANDEL_SIZE     : constant := 4096;
   MANDEL_MAX_ITER : constant := 256;
   TREE_MIN_DEPTH  : constant := 4;
   TREE_MAX_DEPTH  : constant := 18;
   MAX_WORDS       : constant := 32;
   SENTENCE_TEXT   : constant String :=
     "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

   package Secs_IO is new Ada.Text_IO.Fixed_IO (Duration);

   procedure Report (Name : String; Checksum : Long_Long_Integer; Secs : Duration) is
   begin
      Put (Name & " " &
           Ada.Strings.Fixed.Trim (Long_Long_Integer'Image (Checksum), Ada.Strings.Left) & " ");
      Secs_IO.Put (Secs, Fore => 1, Aft => 3);
      New_Line;
   end Report;

   function Since (Start : Time) return Duration is (To_Duration (Clock - Start));

   function Is_Prime (N : Integer) return Boolean is
      I : Integer := 5;
   begin
      if N < 2 then return False; end if;
      if N < 4 then return True; end if;
      if N mod 2 = 0 or else N mod 3 = 0 then return False; end if;
      while I * I <= N loop
         if N mod I = 0 or else N mod (I + 2) = 0 then return False; end if;
         I := I + 6;
      end loop;
      return True;
   end Is_Prime;

   function Bench_Primes (Limit : Integer) return Long_Long_Integer is
      Count : Long_Long_Integer := 0;
   begin
      for I in 2 .. Limit - 1 loop
         if Is_Prime (I) then Count := Count + 1; end if;
      end loop;
      return Count;
   end Bench_Primes;

   function Fib (N : Integer) return Long_Long_Integer is
   begin
      if N < 2 then return Long_Long_Integer (N); end if;
      return Fib (N - 1) + Fib (N - 2);
   end Fib;

   function Bench_Strings (Sentence : String; Iters : Integer) return Long_Long_Integer is
      type String_Access is access String;
      procedure Free is new Ada.Unchecked_Deallocation (String, String_Access);
      Words  : array (1 .. MAX_WORDS) of String_Access;
      WCount : Integer := 0;
      Pos    : Integer := Sentence'First;
      First  : Integer;
      Total  : Long_Long_Integer := 0;
   begin
      while Pos <= Sentence'Last and then WCount < MAX_WORDS loop
         while Pos <= Sentence'Last and then Sentence (Pos) = ' ' loop
            Pos := Pos + 1;
         end loop;
         exit when Pos > Sentence'Last;
         First := Pos;
         while Pos <= Sentence'Last and then Sentence (Pos) /= ' ' loop
            Pos := Pos + 1;
         end loop;
         WCount := WCount + 1;
         Words (WCount) := new String'(Sentence (First .. Pos - 1));
      end loop;

      for It in 1 .. Iters loop
         for I in 1 .. WCount loop
            for J in 1 .. WCount loop
               if Words (I).all = Words (J).all then Total := Total + 1; end if;
            end loop;
         end loop;
      end loop;

      for I in 1 .. WCount loop
         Free (Words (I));
      end loop;
      return Total;
   end Bench_Strings;

   function Bench_Mandelbrot (Size : Integer) return Long_Long_Integer is
      Checksum           : Long_Long_Integer := 0;
      Cx, Cy, Zx, Zy, Nx : Long_Float;
      Iter               : Integer;
   begin
      for Py in 0 .. Size - 1 loop
         Cy := Long_Float (Py) / Long_Float (Size) * 3.0 - 1.5;
         for Px in 0 .. Size - 1 loop
            Cx := Long_Float (Px) / Long_Float (Size) * 3.0 - 2.0;
            Zx := 0.0;
            Zy := 0.0;
            Iter := 0;
            while Iter < MANDEL_MAX_ITER and then Zx * Zx + Zy * Zy <= 4.0 loop
               Nx := Zx * Zx - Zy * Zy + Cx;
               Zy := 2.0 * Zx * Zy + Cy;
               Zx := Nx;
               Iter := Iter + 1;
            end loop;
            Checksum := Checksum + Long_Long_Integer (Iter);
         end loop;
      end loop;
      return Checksum;
   end Bench_Mandelbrot;

   type Tree_Node;
   type Tree_Access is access Tree_Node;
   type Tree_Node is record
      Left, Right : Tree_Access := null;
      Item        : Long_Long_Integer := 0;
   end record;

   procedure Free is new Ada.Unchecked_Deallocation (Tree_Node, Tree_Access);

   function Make_Tree (Item : Long_Long_Integer; Depth : Integer) return Tree_Access is
      N : constant Tree_Access := new Tree_Node'(Left => null, Right => null, Item => Item);
   begin
      if Depth > 0 then
         N.Left := Make_Tree (2 * Item - 1, Depth - 1);
         N.Right := Make_Tree (2 * Item, Depth - 1);
      end if;
      return N;
   end Make_Tree;

   function Check_Tree (N : Tree_Access) return Long_Long_Integer is
   begin
      if N.Left = null then return N.Item; end if;
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

   function Bench_Binary_Trees (Max_Depth : Integer) return Long_Long_Integer is
      Checksum   : Long_Long_Integer := 0;
      Stretch    : Tree_Access := Make_Tree (0, Max_Depth + 1);
      Long_Lived : Tree_Access;
      T          : Tree_Access;
      D          : Integer := TREE_MIN_DEPTH;
   begin
      Checksum := Checksum + Check_Tree (Stretch);
      Free_Tree (Stretch);
      Long_Lived := Make_Tree (0, Max_Depth);
      while D <= Max_Depth loop
         for I in 0 .. 2 ** (Max_Depth - D + TREE_MIN_DEPTH) - 1 loop
            T := Make_Tree (Long_Long_Integer (I + 1), D);
            Checksum := Checksum + Check_Tree (T);
            Free_Tree (T);
         end loop;
         D := D + 2;
      end loop;
      Checksum := Checksum + Check_Tree (Long_Lived);
      Free_Tree (Long_Lived);
      return Checksum;
   end Bench_Binary_Trees;

   T        : Time;
   R        : Long_Long_Integer;
begin
   T := Clock; R := Bench_Primes (PRIMES_LIMIT);          Report ("primes", R, Since (T));
   T := Clock; R := Fib (FIBONACCI_N);                     Report ("fib", R, Since (T));
   T := Clock; R := Bench_Strings (SENTENCE_TEXT, STRING_ITER); Report ("strings", R, Since (T));
   T := Clock; R := Bench_Mandelbrot (MANDEL_SIZE);        Report ("mandelbrot", R, Since (T));
   T := Clock; R := Bench_Binary_Trees (TREE_MAX_DEPTH);   Report ("binarytrees", R, Since (T));
end Bench;
