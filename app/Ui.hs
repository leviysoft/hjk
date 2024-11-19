{-# LANGUAGE OverloadedStrings #-}

module Ui where

import Data.Text (Text)
import Options.Applicative hiding (empty)
import Options.Applicative.Text

data Args = Args
  { task :: Text,
    buildFile :: Text
  }

args :: Parser Args
args =
  Args
    <$> argument text (metavar "COMMAND" <> help "Command to run")
    <*> textOption (metavar "BUILD_FILE" <> help "Path to the build file" <> showDefault <> value "build.dhall")

argsInfo :: ParserInfo Args
argsInfo = info args fullDesc