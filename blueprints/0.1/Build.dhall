let Tasks = ./Task.dhall

let Build
    : Type
    = { tasks : List Tasks.Task }

in  Build
