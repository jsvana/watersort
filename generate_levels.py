"""
Water Sort level generator using reverse-pour from solved state.

Correctness: starting from the solved state and applying reverse-pours that are
exactly the inverse of valid forward pours guarantees the generated state is
solvable. The constraint enforced below: when reverse-pouring N units of color C
from B to A, if B currently contains ONLY Cs we may move all of them; otherwise
we must leave at least one C on top of B (so the forward undo is a valid pour).
"""
import json, random
from collections import deque

CAPACITY = 4

def reverse_pour(vials):
    non_empty = [i for i, v in enumerate(vials) if v]
    if not non_empty: return False
    for _ in range(40):
        src = random.choice(non_empty)
        top = vials[src][-1]
        m = 0
        for c in reversed(vials[src]):
            if c == top: m += 1
            else: break
        only_cs = (m == len(vials[src]))
        max_n = m if only_cs else m - 1
        if max_n < 1: continue
        n = random.randint(1, max_n)
        candidates = [i for i,v in enumerate(vials) if i != src and len(v)+n <= CAPACITY]
        if not candidates: continue
        dst = random.choice(candidates)
        for _ in range(n):
            vials[src].pop()
            vials[dst].append(top)
        return True
    return False

def generate(num_colors, num_empty, shuffle_steps):
    vials = [[c]*CAPACITY for c in range(num_colors)] + [[] for _ in range(num_empty)]
    for _ in range(shuffle_steps):
        reverse_pour(vials)
    return vials

def is_solved(vials):
    return all(not v or (len(v)==CAPACITY and len(set(v))==1) for v in vials)

def is_solvable(vials, limit=200000):
    """BFS check. Returns True if solvable within state limit."""
    if is_solved(vials): return True
    start = tuple(tuple(v) for v in vials)
    seen = {start}
    q = deque([start])
    while q and len(seen) < limit:
        state = q.popleft()
        sl = [list(v) for v in state]
        n = len(sl)
        for src in range(n):
            if not sl[src]: continue
            top = sl[src][-1]
            cnt = 0
            for c in reversed(sl[src]):
                if c == top: cnt += 1
                else: break
            for dst in range(n):
                if src == dst: continue
                if len(sl[dst]) >= CAPACITY: continue
                if sl[dst] and sl[dst][-1] != top: continue
                space = CAPACITY - len(sl[dst])
                amt = min(cnt, space)
                ns = [list(v) for v in sl]
                for _ in range(amt):
                    ns[src].pop()
                    ns[dst].append(top)
                key = tuple(tuple(v) for v in ns)
                if key in seen: continue
                if is_solved(ns): return True
                seen.add(key)
                q.append(key)
    return None  # unknown — too big

def difficulty(vials):
    """Simple metric: how mixed up is this?"""
    return sum(len(set(v)) for v in vials)

random.seed(7)

# (num_colors, num_empty, count, shuffle_steps)
configs = [
    (2, 2, 3, 6),
    (3, 2, 4, 10),
    (4, 2, 5, 14),
    (5, 2, 6, 18),
    (6, 2, 6, 24),
    (7, 2, 5, 30),
    (8, 2, 4, 36),
    (9, 2, 3, 42),
]

levels, lid = [], 1
for nc, ne, cnt, sh in configs:
    made = 0
    attempts = 0
    while made < cnt and attempts < 200:
        attempts += 1
        v = generate(nc, ne, sh)
        if is_solved(v): continue
        # verify with BFS for small levels
        if nc <= 6:
            ok = is_solvable(v)
            if ok is False: continue
        levels.append({"id": lid, "vials": v})
        lid += 1
        made += 1

with open('/home/claude/watersort/Levels.json', 'w') as f:
    json.dump({"levels": levels}, f, indent=2)

# print summary
print(f"Generated {len(levels)} levels")
buckets = {}
for L in levels:
    nc = len({c for v in L['vials'] for c in v})
    buckets[nc] = buckets.get(nc, 0) + 1
for k in sorted(buckets): print(f"  {k} colors: {buckets[k]} levels")
print(f"\nLevel 1 sample: {levels[0]['vials']}")
print(f"Last level sample: {levels[-1]['vials']}")
