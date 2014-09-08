function __fish_ndkenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'ndkenv' ]
    return 0
  end
  return 1
end

function __fish_ndkenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c ndkenv -n '__fish_ndkenv_needs_command' -a '(ndkenv commands)'
for cmd in (ndkenv commands)
  complete -f -c ndkenv -n "__fish_ndkenv_using_command $cmd" -a "(ndkenv completions $cmd)"
end
