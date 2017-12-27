#!/bin/bash

nooom() {
    "$*" >&/dev/null &
    local procid="$!"
    echo -999 | sudo tee /proc/${procid}/oom_score_adj
    disown %%
}

