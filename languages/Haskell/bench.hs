{-# LANGUAGE GHC2024 #-}

module Main (main) where

import Control.Exception (evaluate)
import Data.Bits (shiftL)
import Data.ByteString.Char8 qualified as B
import Data.Int (Int32)
import Data.List (sortBy)
import Data.Map.Strict qualified as M
import Data.Ord (Down (..), comparing)
import Data.Sequence qualified as Seq
import GHC.Clock (getMonotonicTime)
import Text.Printf (printf)

primesLimit :: Int32
primesLimit = 8_000_000

fibonacciN, stringIter, mandelSize, mandelMaxIter, treeMinDepth, treeMaxDepth :: Int
fibonacciN = 43
stringIter = 1_200_000
mandelSize = 2048
mandelMaxIter = 256
treeMinDepth = 4
treeMaxDepth = 17

knucLength, knucSeed, knucIm, knucIa, knucIc :: Int
knucLength = 6_000_000
knucSeed = 42
knucIm = 139_968
knucIa = 3877
knucIc = 29_573

knucKs :: [Int]
knucKs = [1, 2, 3, 4, 6, 12, 18]

sentence, knucQuery :: B.ByteString
sentence = B.pack "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again"
knucQuery = B.pack "GGTATTTTAATTTATAGT"

timed :: String -> Int -> IO ()
timed name work = do
  start <- getMonotonicTime
  checksum <- evaluate work
  end <- getMonotonicTime
  printf "%s %d %.3f\n" name checksum (end - start)

isPrime :: Int32 -> Bool
isPrime n
  | n < 2 = False
  | n < 4 = True
  | n `rem` 2 == 0 || n `rem` 3 == 0 = False
  | otherwise = go 5
  where
    go !i
      | i * i > n = True
      | n `rem` i == 0 || n `rem` (i + 2) == 0 = False
      | otherwise = go (i + 6)

{-# NOINLINE benchPrimes #-}
benchPrimes :: Int32 -> Int
benchPrimes limit = length (filter isPrime [2 .. limit - 1])

fib :: Int -> Int
fib n
  | n < 2 = n
  | otherwise = fib (n - 1) + fib (n - 2)

{-# NOINLINE benchStrings #-}
benchStrings :: B.ByteString -> Int -> Int
benchStrings text iters = go 0 (Seq.fromList ws) 0
  where
    ws = B.split ' ' text
    n = length ws
    go !it !cur !total
      | it == iters = total
      | otherwise =
          let !cur' = Seq.adjust' B.reverse (it `rem` n) cur
           in go (it + 1) cur' (foldl' row total cur')
    row acc wi = foldl' (\acc' wj -> if wi == wj then acc' + 1 else acc') acc ws

benchMandelbrot :: Int -> Int
benchMandelbrot size =
  sum
    [ escape cx cy 0.0 0.0 0
    | py <- [0 .. size - 1]
    , let cy = fromIntegral py / fsize * 3.0 - 1.5
    , px <- [0 .. size - 1]
    , let cx = fromIntegral px / fsize * 3.0 - 2.0
    ]
  where
    fsize = fromIntegral size :: Double
    escape :: Double -> Double -> Double -> Double -> Int -> Int
    escape cx cy !zx !zy !iter
      | iter < mandelMaxIter && zx * zx + zy * zy <= 4.0 =
          escape cx cy (zx * zx - zy * zy + cx) (2.0 * zx * zy + cy) (iter + 1)
      | otherwise = iter

data Tree = Empty | Node !Tree !Tree !Int

makeTree :: Int -> Int -> Tree
makeTree item 0 = Node Empty Empty item
makeTree item depth = Node (makeTree (2 * item - 1) (depth - 1)) (makeTree (2 * item) (depth - 1)) item

checkTree :: Tree -> Int
checkTree (Node Empty _ item) = item
checkTree (Node left right item) = item + checkTree left - checkTree right
checkTree Empty = 0

{-# NOINLINE benchBinaryTrees #-}
benchBinaryTrees :: Int -> Int
benchBinaryTrees maxDepth =
  let !stretch = checkTree (makeTree 0 (maxDepth + 1))
   in let !longLived = makeTree 0 maxDepth
       in let !iterations = depths treeMinDepth stretch
           in iterations + checkTree longLived
  where
    depths !d !checksum
      | d > maxDepth = checksum
      | otherwise = depths (d + 2) (trees d (1 `shiftL` (maxDepth - d + treeMinDepth)) 0 checksum)
    trees !d !iters !i !checksum
      | i == iters = checksum
      | otherwise = trees d iters (i + 1) (checksum + checkTree (makeTree (i + 1) d))

{-# NOINLINE benchKnucleotide #-}
benchKnucleotide :: Int -> Int
benchKnucleotide len = foldl' frequencies 0 knucKs
  where
    dna = fst (B.unfoldrN len next knucSeed)
    next seed =
      let !s = (seed * knucIa + knucIc) `rem` knucIm
       in Just (nucleotide s, s)
    nucleotide s
      | s < 42404 = 'A'
      | s < 70116 = 'C'
      | s < 97766 = 'G'
      | otherwise = 'T'
    frequencies !checksum k =
      let counts = foldl' (\m i -> M.insertWith (+) (B.take k (B.drop i dna)) 1 m) M.empty [0 .. len - k]
          !distinct = checksum + M.size counts
       in if k <= 2
            then distinct + sum (zipWith (*) [1 ..] (map snd (sortBy (comparing (Down . snd) <> comparing fst) (M.toList counts))))
            else distinct + M.findWithDefault 0 (B.take k knucQuery) counts

main :: IO ()
main = do
  timed "primes" (benchPrimes primesLimit)
  timed "fib" (fib fibonacciN)
  timed "strings" (benchStrings sentence stringIter)
  timed "mandelbrot" (benchMandelbrot mandelSize)
  timed "binarytrees" (benchBinaryTrees treeMaxDepth)
  timed "knucleotide" (benchKnucleotide knucLength)
