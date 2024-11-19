{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}

module Procedures where

import Data.Foldable (toList)
import Data.Functor
import Data.List (intercalate)
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
import Prelude hiding (lines, map)

findSources :: FilePath -> [Pattern] -> IO (Seq FilePath)
findSources dest patterns = do
  logger <- getLogger "hjk.sourcefinder"
  logL logger DEBUG (printf "Searching for %s" $ intercalate "," (decompile <$> patterns))
  contents <- pathWalkAccumulate dest $ \dir _ seqFiles ->
    let relativeDir = normalise $ makeRelative dest dir
        full = fmap (combine relativeDir) seqFiles
     in return $ Seq.fromList full
  let filtered = Seq.filter (\path -> any (`match` path) patterns) contents
  logL logger DEBUG (printf "Found %d matching files (of %d total)" (length filtered) (length contents))
  return filtered

runTask :: FilePath -> (Text -> Task) -> Task -> IO Text
runTask dest _ (Simple task) = do
  logger <- getLogger "hjk.executor"
  logL logger DEBUG (printf "Executing '%s'" task.name)
  let patterns = task.globs :: [Pattern]
  sources <- findSources dest patterns
  let sourcesList = toList $ fmap pack sources
  let commandLine = task.cmd sourcesList
  let taskProc = shell $ unpack commandLine
  cmdResult <- readCreateProcess taskProc ""
  logL logger DEBUG (printf "Done executing '%s'" task.name)
  return $ pack cmdResult
runTask dest taskByName (Dependent task) = do
  logger <- getLogger "hjk.executor"
  logL logger DEBUG (printf "Executing '%s'" task.name)
  let patterns = task.globs :: [Pattern]
  sources <- findSources dest patterns
  let sourcesList = toList $ fmap pack sources
  logL logger DEBUG (printf "Calling required task '%s'" task.dependsOn)
  let dependsOnTask = taskByName task.dependsOn
  dependsOnTaskResult <- runTask dest taskByName dependsOnTask
  logL logger DEBUG (printf "Required task '%s' done" task.dependsOn)
  let commandLine = task.cmd sourcesList $ lines dependsOnTaskResult
  let taskProc = shell $ unpack commandLine
  cmdResult <- readCreateProcess taskProc ""
  logL logger DEBUG (printf "Done executing '%s'" task.name)
  return $ pack cmdResult
