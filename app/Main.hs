{-# LANGUAGE OverloadedRecordDot #-}

module Main (main) where

import qualified Data.Map as Map
import Data.Text (unpack)
import Data.Text.IO
import Dhall hiding (map)
import Model
import Options.Applicative hiding (auto, empty)
import Procedures
import System.Directory (getCurrentDirectory)
import Ui
import Prelude hiding (readFile)

main :: IO ()
main = do
  workingDir <- getCurrentDirectory
  arguments <- execParser argsInfo
  buildDefnText <- readFile $ unpack arguments.buildFile
  buildDefn <- input auto buildDefnText :: IO Build
  let taskMap = Map.fromList $ map (\t -> (getTaskName t, t)) buildDefn.tasks
  let taskToRun = taskMap Map.! arguments.task
  result <- runTask workingDir (taskMap Map.!) taskToRun
  print result
