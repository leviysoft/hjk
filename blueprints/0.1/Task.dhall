let SimpleTask =
      { Type = { name : Text, globs : List Text, cmd : List Text -> Text }
      , default.globs = [] : List Text
      }

let DependentTask =
      { Type =
          { name : Text
          , globs : List Text
          , dependsOn : Text
          , cmd : List Text -> List Text -> Text
          }
      , default.globs = [] : List Text
      }

let Task = < Simple : SimpleTask.Type | Dependent : DependentTask.Type >

in  { SimpleTask, DependentTask, Task }
