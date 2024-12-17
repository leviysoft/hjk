let Dependency = ./Dependency.dhall

let formatDep =
      \(d : Dependency.Type) ->
        if    d.cross
        then  "${d.group}::${d.module}:${d.version}"
        else  "${d.group}:${d.module}:${d.version}"

in  formatDep
