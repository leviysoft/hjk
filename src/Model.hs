{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Model where

import Dhall
import System.FilePath.Glob (Pattern, compile)
import Text.Show.Functions ()

instance FromDhall Pattern where
  autoWith _ = fmap compile string

data SimpleTask = SimpleTask
  { name :: Text,
    globs :: [Pattern],
    cmd :: [Text] -> Text
  }
  deriving (Generic, Show)

instance FromDhall SimpleTask

data DependentTask = DependentTask
  { name :: Text,
    globs :: [Pattern],
    cmd :: [Text] -> [Text] -> Text,
    dependsOn :: Text
  }
  deriving (Generic, Show)

instance FromDhall DependentTask

data Task
  = Simple SimpleTask
  | Dependent DependentTask
  deriving (Generic, Show)

instance FromDhall Task

getTaskName :: Task -> Text
getTaskName (Simple t) = t.name
getTaskName (Dependent t) = t.name

data Build = Build
  { tasks :: [Task]
  }
  deriving (Generic, Show)

instance FromDhall Build
