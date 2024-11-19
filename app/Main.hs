{-# LANGUAGE OverloadedRecordDot #-}

module Main (main) where

import Control.Monad.Extra
import qualified Data.Map as Map
import Data.Text (null, unpack)
import Data.Text.IO
import Dhall hiding (map)
import Model
import Options.Applicative hiding (auto, empty)
import Procedures
import System.Directory (getCurrentDirectory)
import System.Log.Logger
import Ui
import Prelude hiding (null, readFile)

main :: IO ()
main = do
  logger <- getLogger "hjk"
  workingDir <- getCurrentDirectory
  arguments <- execParser argsInfo
  let logLevel = if arguments.debug then DEBUG else INFO
  let logger' = setLevel logLevel logger
  saveGlobalLogger logger'
  buildDefnText <- readFile $ unpack arguments.buildFile
  buildDefn <- input auto buildDefnText :: IO Build
  let taskMap = Map.fromList $ map (\t -> (getTaskName t, t)) buildDefn.tasks
  let taskToRun = taskMap Map.! arguments.task
  result <- runTask workingDir (taskMap Map.!) taskToRun
  unless (null result) $ print result
