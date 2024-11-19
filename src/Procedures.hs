{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module Procedures where

import Data.Foldable (toList)
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq
import Data.Text (Text, lines, pack, unpack)
import Model
import System.Directory.PathWalk
import System.FilePath
import System.FilePath.Glob (Pattern, decompile, match)
import System.Log.Logger
import System.Process
import Text.Printf (printf)
import Prelude hiding (lines)

findSources :: FilePath -> Pattern -> IO (Seq FilePath)
findSources dest glob = do
  logger <- getLogger "hjk.sourcefinder"
  logL logger DEBUG (printf "Searching for %s" $ decompile glob)
  contents <- pathWalkAccumulate dest $ \dir _ seqFiles ->
    let relativeDir = normalise $ makeRelative dest dir
        full = map (combine relativeDir) seqFiles
     in return $ Seq.fromList full
  let filtered = Seq.filter (match glob) contents
  logL logger DEBUG (printf "Found %d matching files (of %d total)" (length filtered) (length contents))
  return filtered

runTask :: FilePath -> (Text -> Task) -> Task -> IO Text
runTask dest _ (Simple task) = do
  logger <- getLogger "hjk.executor"
  logL logger DEBUG (printf "Executing '%s'" task.name)
  let patterns = task.globs :: [Pattern]
  sources <- mapM (findSources dest) patterns
  let flatSources = toList =<< sources
  let commandLine = task.cmd $ map pack flatSources
  let taskProc = shell $ unpack commandLine
  cmdResult <- readCreateProcess taskProc ""
  logL logger DEBUG (printf "Done executing '%s'" task.name)
  return $ pack cmdResult
runTask dest taskByName (Dependent task) = do
  logger <- getLogger "hjk.executor"
  logL logger DEBUG (printf "Executing '%s'" task.name)
  let patterns = task.globs :: [Pattern]
  sources <- mapM (findSources dest) patterns
  let flatSources = pack <$> (toList =<< sources)
  logL logger DEBUG (printf "Calling required task '%s'" task.dependsOn)
  let dependsOnTask = taskByName task.dependsOn
  dependsOnTaskResult <- runTask dest taskByName dependsOnTask
  logL logger DEBUG (printf "Required task '%s' done" task.dependsOn)
  let commandLine = task.cmd flatSources $ lines dependsOnTaskResult
  let taskProc = shell $ unpack commandLine
  cmdResult <- readCreateProcess taskProc ""
  logL logger DEBUG (printf "Done executing '%s'" task.name)
  return $ pack cmdResult
