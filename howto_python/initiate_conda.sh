#! /bin/bash

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/autofs/space/symphony_002/users/kwokshing/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/autofs/space/symphony_002/users/kwokshing/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/autofs/space/symphony_002/users/kwokshing/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/autofs/space/symphony_002/users/kwokshing/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

# >>> conda initialize >>>

## Miniforge
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/autofs/space/symphony_002/users/kwokshing/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/autofs/space/symphony_002/users/kwokshing/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/autofs/space/symphony_002/users/kwokshing/anacominiforge3da3/etc/profile.d/conda.sh"
    else
        export PATH="/autofs/space/symphony_002/users/kwokshing/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
