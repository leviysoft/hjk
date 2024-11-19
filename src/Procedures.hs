{-# LANGUAGE OverloadedRecordDot #-}

module Procedures where

import Data.Foldable (toList)
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq
import Data.Text (Text, lines, pack, unpack)
import Model
import System.Directory.PathWalk
import System.FilePath
import System.FilePath.Glob (Pattern, match)
import System.Process
import Prelude hiding (lines)

findSources :: FilePath -> Pattern -> IO (Seq FilePath)
findSources dest glob = do
  contents <- pathWalkAccumulate dest $ \dir _ seqFiles ->
    let relativeDir = normalise $ makeRelative dest dir
        full = map (combine relativeDir) seqFiles
     in return $ Seq.fromList full
  return $ Seq.filter (match glob) contents

runTask :: FilePath -> (Text -> Task) -> Task -> IO Text
runTask dest _ (Simple task) = do
  let patterns = task.globs :: [Pattern]
  sources <- mapM (findSources dest) patterns
  let flatSources = toList =<< sources
  let commandLine = task.cmd $ map pack flatSources
  let taskProc = shell $ unpack commandLine
  cmdResult <- readCreateProcess taskProc ""
  return $ pack cmdResult
runTask dest taskByName (Dependent task) = do
  let patterns = task.globs :: [Pattern]
  sources <- mapM (findSources dest) patterns
  let flatSources = pack <$> (toList =<< sources)
  let dependsOnTask = taskByName task.dependsOn
  dependsOnTaskResult <- runTask dest taskByName dependsOnTask
  let commandLine = task.cmd flatSources $ lines dependsOnTaskResult
  let taskProc = shell $ unpack commandLine
  cmdResult <- readCreateProcess taskProc ""
  return $ pack cmdResult
