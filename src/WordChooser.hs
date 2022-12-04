module WordChooser (
    
) where

{-# LANGUAGE BlockArguments #-}

import Data.List (group, sort, groupBy, sortBy, elemIndex, maximumBy)
import Data.Maybe (fromJust, isNothing, mapMaybe)
import Data.HashMap.Strict (HashMap, fromList, member, update)
import Control.Monad (unless)
import BananaBoard

type Hand = HashMap Char Int

playTile :: Char -> Hand -> Hand
playTile = update dec
    where dec :: Int -> Maybe Int
          dec 1 = Nothing
          dec n = Just (n-1)

splitDict :: [String] -> [[String]]
splitDict dict = groupBy lengthEq $ sortBy lengthCmp dict
    where lengthCmp x y = length y `compare` length x
          lengthEq x y = length x == length y

toHand :: String -> Hand
toHand hand = fromList $ map (\s -> (head s, length s)) 
    $ (group . sort) hand

buildWord :: String -> Hand -> Maybe Hand
buildWord [] hand = Just hand
buildWord (w:ws) hand
    | null hand || not (member w hand) = Nothing
    | otherwise = buildWord ws $ playTile w hand  

buildWords :: [String] -> Hand -> [(String, Hand)]
buildWords dict hand = mapMaybe bw_pair dict
    where 
          bw word = buildWord word hand
          bw_pair word = case bw word of
            Nothing -> Nothing
            Just hand -> Just (word, hand)

bestWord :: [(String, Hand)] -> Maybe (String, Hand)
bestWord [] = Nothing
bestWord buildables = Just $ maximumBy scoreCmp buildables
    where 
        scoreCmp (x, _) (y, _) = scoreWord x `compare` scoreWord y
        scoreWord :: String -> Int
        scoreWord w = sum $ map scoreChar w
        
        scoreChar :: Char -> Int
        scoreChar c = fromJust $ elemIndex c freqOrd
        -- see https://en.wikipedia.org/wiki/Letter_frequency
        freqOrd = "esiarntolcdugpmhbyfvkwzxjq"


playFirstWord :: Hand -> [[String]] -> Maybe (Hand, Board)
playFirstWord hand [] = Nothing
playFirstWord hand (d:ds)
    | isNothing best = playFirstWord hand ds
    | otherwise = let (word, newhand) = fromJust best in
        Just (newhand, singleton word)
    where 
          buildables = buildWords d hand
          best = bestWord buildables

main :: IO ()
main = do
    fcontents <- readFile "../words.txt"
    let dict = splitDict $ words fcontents
    let hand = toHand "riggyalarcwgbit"
    print $ playFirstWord hand dict
