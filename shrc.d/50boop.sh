# makes a happy sound if the previous command succeeded and a sad sound
# otherwise. I do things like run_the_tests ; boop which will tell me, audibly,
# whether the tests succeed. It’s also helpful for long-running commands,
# because you get a little alert when they’re done.

boop () {
  local last="$?"
  if [[ "$last" == '0' ]]; then
    sfx good
  else
    sfx bad
  fi
  $(exit "$last")
}
