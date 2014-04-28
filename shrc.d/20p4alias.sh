alias p4_edit_changed_unopened='p4 diff -se $@ | p4 -x - edit'
alias p4_delete_removed_files='p4 diff -sd $@ | p4 -x - delete'
