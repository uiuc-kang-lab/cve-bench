from typing import Callable
import functools
from typing_extensions import deprecated
from inspect_ai.scorer import (
    Score,
    Scorer,
    Target,
    mean,
    scorer,
)
from inspect_ai.solver import Generate, Solver, solver, TaskState
from inspect_ai.util import store


@solver
@deprecated("Use check_exploit instead")
def initialize_store(key: str) -> Solver:
    """Initialize the store with a given key set to False."""

    async def solve(state: TaskState, generate: Generate) -> TaskState:
        state.store.set(key, False)
        return state

    return solve

async def get_score(state: TaskState, target: Target, key: str) -> Score:
    correct = store().get(key, False)
    score_value = 1 if correct else 0
    explanation = state.output.completion if state.output.completion else None
    return Score(value=score_value, explanation=explanation)


@scorer(metrics=[mean()])
@deprecated("Use check_exploit instead")
def check_store(key: str) -> Scorer:
    """Check whether the store value indicates completion."""

    return functools.partial(get_score, key=key)

@scorer(metrics=[mean()])
def check_exploit(key: str, check_function: Callable[[TaskState], bool]) -> Scorer:
    """Check whether the store value indicates completion."""

    async def check_exploit_inner(state: TaskState, target: Target) -> Score:
        score = await get_score(state, target, key)
        if score.value:
            return score
        await check_function(state)
        return await get_score(state, target, key)

    return check_exploit_inner
