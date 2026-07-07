#!/usr/bin/env bash
# Non-deterministic evaluation harness for the ai-output-humanizer skill.
# Runs k trials per test case, collects session-enriched JSONL logs,
# computes pass^k metrics, and produces a summary report.
#
# Usage: evaluate-superset.sh [--k N] [--only TC-NN] [--skip-exercise]
#   --k N           Number of trials per test case (default: 3, min: 3, recommended: 5)
#   --only TC-NN    Run a single test case (e.g., TC-01)
#   --skip-exercise Skip the exercise step (use existing outputs)
#   --help          Show this message
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL_DIR="${REPO}/skills/ai-output-humanizer"
SKILL_MD="${SKILL_DIR}/SKILL.md"
INPUTS_DIR="${REPO}/tests/superset/inputs"
RESULTS_DIR="${REPO}/tests/superset/results"
LOGS_DIR="${RESULTS_DIR}/logs"
HARNESS_DIR="${REPO}/tests/harness"

K=3
ONLY=""
SKIP_EXERCISE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --k) K="$2"; shift 2 ;;
    --only) ONLY="$2"; shift 2 ;;
    --skip-exercise) SKIP_EXERCISE=true; shift ;;
    --help) head -20 "$0" | sed 's/^# //'; exit 0 ;;
    *) echo "unknown option: $1"; exit 1 ;;
  esac
done

if [ "$K" -lt 3 ]; then
  echo "error: k must be >= 3 (got $K)" >&2
  exit 1
fi

if [ ! -f "$SKILL_MD" ]; then
  echo "error: SKILL.md not found at $SKILL_MD" >&2
  exit 1
fi

mkdir -p "$RESULTS_DIR" "$LOGS_DIR"

SESSION="$(uuidgen 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')"
COMMIT="$(cd "$REPO" && git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
THRESHOLD=0.67
START_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Test case definitions
# Format: id|name|input_file|mode|voice_sample|judge_criteria
declare -A TC_NAME TC_INPUT TC_MODE TC_VOICE TC_CRITERIA

register_tc() {
  local id="$1" name="$2" input="$3" mode="$4" voice="$5" criteria="$6"
  TC_NAME["$id"]="$name"
  TC_INPUT["$id"]="$input"
  TC_MODE["$id"]="$mode"
  TC_VOICE["$id"]="$voice"
  TC_CRITERIA["$id"]="$criteria"
}

register_tc "TC-01" "Happy path (standard rewrite)" "tc01-happy-path.txt" "rewrite" "" \
  "No em dashes present|No 'it is not X it is Y' constructions|No 'let us' transitions|No 'it is worth noting' or 'in conclusion'|Sentence length varies|Reads as a person wrote it"

register_tc "TC-02" "Detect mode (flag only)" "tc02-detect-mode.txt" "detect" "" \
  "Original text is preserved|At least 3 AI patterns identified|Patterns are grouped or categorized|No rewritten version produced"

register_tc "TC-03" "Edit mode (in-place)" "tc03-edit-mode.txt" "edit" "" \
  "Describes edit mode workflow correctly|Identifies which patterns to fix|Proposes targeted not full rewrite|Follows edit mode output format"

register_tc "TC-04" "Voice calibration" "tc04-voice-calibration.txt" "rewrite" "tc04-voice-sample.txt" \
  "Matches sample sentence length|Matches sample casual register|First-person perspective present|Vocabulary not upgraded"

register_tc "TC-05" "Opt-out (technical docs)" "tc05-opt-out.txt" "rewrite" "" \
  "Technical terms preserved|Output not made informal|Changes are minimal|Opt-out context acknowledged"

register_tc "TC-06" "Convergence (iterate)" "tc06-convergence.txt" "rewrite" "" \
  "Second-pass audit performed|Remaining tells fixed|Final output has fewer patterns|Process reported"

register_tc "TC-07" "Ethics framing" "tc07-ethics-framing.txt" "rewrite" "" \
  "Ethics framing referenced|False positives acknowledged|No definitive AI claims|Non-native patterns handled with care"

register_tc "TC-08" "Adversarial (non-native)" "tc08-adversarial.txt" "rewrite" "" \
  "Zero patterns flagged|Second-language origin acknowledged|Original meaning preserved|Grammar not aggressively corrected"

# Determine which test cases to run
ALL_TCS=()
for id in "TC-01" "TC-02" "TC-04" "TC-05" "TC-06" "TC-07" "TC-08"; do
  ALL_TCS+=("$id")
done

RUN_CASES=()
if [ -n "$ONLY" ]; then
  if [ -z "${TC_NAME[$ONLY]:-}" ]; then
    echo "error: unknown test case '$ONLY'. Valid: ${ALL_TCS[*]}" >&2
    exit 1
  fi
  RUN_CASES=("$ONLY")
else
  RUN_CASES=("${ALL_TCS[@]}")
fi

# Write session header
SESSION_LOG="${LOGS_DIR}/${SESSION}.jsonl"
echo "session: $SESSION"
echo "commit: $COMMIT"
echo "k: $K"
echo "threshold: $THRESHOLD"
echo "test cases: ${RUN_CASES[*]}"
echo "log: $SESSION_LOG"
echo ""

python3 -c "
import json
log = open('${SESSION_LOG}', 'w')
log.write(json.dumps({
  'type': 'session-start',
  'session': '${SESSION}',
  'commit': '${COMMIT}',
  'k': ${K},
  'threshold': ${THRESHOLD},
  'corpus': 'tests/superset/inputs/',
  'timestamp': '${START_TS}'
}) + '\n')
log.close()
"

TOTAL_CASES=${#RUN_CASES[@]}
TOTAL_PASS=0
DURATION_START=$(date +%s)

exercise_one() {
  local input_file="$1"
  local mode="$2"
  local voice_sample="$3"
  local run="$4"
  local tmp
  tmp=$(mktemp -d)

  # For edit mode, write the input to a real file so the agent can Read+Edit it.
  if [ "$mode" = "edit" ]; then
    local edit_file="${tmp}/draft.md"
    cp "$input_file" "$edit_file"
  fi

  {
    printf '=== SKILL INSTRUCTIONS BEGIN ===\n'
    cat "$SKILL_MD"
    printf '\n=== SKILL INSTRUCTIONS END ===\n\n'

    if [ "$mode" = "detect" ]; then
      printf 'detect\n\n'
      printf '=== TEXT TO PROCESS BEGIN ===\n'
      cat "$input_file"
      printf '\n=== TEXT TO PROCESS END ===\n\n'
    elif [ "$mode" = "edit" ]; then
      printf 'edit\n\n'
      printf '=== TEXT TO PROCESS BEGIN ===\n'
      cat "$input_file"
      printf '\n=== TEXT TO PROCESS END ===\n\n'
    else
      printf 'rewrite\n\n'
      printf '=== TEXT TO PROCESS BEGIN ===\n'
      cat "$input_file"
      printf '\n=== TEXT TO PROCESS END ===\n\n'
    fi

    if [ -n "$voice_sample" ] && [ -f "$voice_sample" ]; then
      printf '=== VOICE SAMPLE BEGIN ===\n'
      cat "$voice_sample"
      printf '\n=== VOICE SAMPLE END ===\n\n'
    fi
  } > "${tmp}/prompt.md"

  if ! opencode run --format json --dangerously-skip-permissions \
        < "${tmp}/prompt.md" \
        > "${tmp}/raw.json" 2>"${tmp}/stderr.log"; then
    echo "    opencode run failed (run $run); see ${tmp}/stderr.log" >&2
    rm -rf "$tmp"
    return 1
  fi

  local out="${tmp}/output.md"
  if ! python3 "${HARNESS_DIR}/extract-output.py" "${tmp}/raw.json" "${out}"; then
    echo "    failed to parse output (run $run)" >&2
    rm -rf "$tmp"
    return 1
  fi

  cat "$out"
  rm -rf "$tmp"
}

judge_output() {
  local tc_id="$1"
  local input_text="$2"
  local output_text="$3"
  local criteria="${TC_CRITERIA[$tc_id]}"
  local tmp
  tmp=$(mktemp -d)

  python3 -c "
import sys
skill = open('${SKILL_MD}').read()
inp = '''${input_text}'''
out = '''${output_text}'''
criteria = '''${criteria}'''
tc_name = '''${TC_NAME[$tc_id]}'''
tc_mode = '''${TC_MODE[$tc_id]}'''

prompt = f'''You are a strict judge evaluating an AI-output-humanizer skill.

Test case: {tc_name}
Mode: {tc_mode}

Judge criteria:
{criteria.replace(chr(124), chr(10) + '- ')}

=== SKILL.md BEGIN ===
{skill}
=== SKILL.md END ===

=== ORIGINAL INPUT BEGIN ===
{inp}
=== ORIGINAL INPUT END ===

=== REWRITTEN OUTPUT BEGIN ===
{out}
=== REWRITTEN OUTPUT END ===

Score the output against the judge criteria. Return STRICT JSON only — no prose, no markdown fences.

Use this schema:
{{"result": "pass"|"fail"|"skip", "reason": "explanation", "confidence": 0.0-1.0}}
'''
print(prompt)
" > "${tmp}/judge-prompt.md"

  if ! opencode run --format json --dangerously-skip-permissions \
        < "${tmp}/judge-prompt.md" \
        > "${tmp}/judge-raw.json" 2>"${tmp}/judge-stderr.log"; then
    echo "    judge failed; see ${tmp}/judge-stderr.log" >&2
    rm -rf "$tmp"
    echo '{"result":"fail","reason":"judge invocation failed","confidence":0.0}'
    return
  fi

  local extracted="${tmp}/judge-out.md"
  python3 "${HARNESS_DIR}/extract-output.py" "${tmp}/judge-raw.json" "${extracted}" 2>/dev/null || true
  local text
  text=$(cat "$extracted" 2>/dev/null || echo '{"result":"fail","reason":"extract failed","confidence":0.0}')

  # Strip markdown fences if present
  if echo "$text" | head -1 | grep -q '```'; then
    text=$(echo "$text" | sed '1s/^```json//;1s/^```//;$s/```$//')
  fi

  echo "$text"
  rm -rf "$tmp"
}

for tc in "${RUN_CASES[@]}"; do
  input_file="${INPUTS_DIR}/${TC_INPUT[$tc]}"
  if [ ! -f "$input_file" ]; then
    echo "warning: input not found for $tc (${TC_INPUT[$tc]}), skipping" >&2
    continue
  fi

  input_text=$(cat "$input_file")
  voice_file=""
  if [ -n "${TC_VOICE[$tc]:-}" ]; then
    voice_file="${INPUTS_DIR}/${TC_VOICE[$tc]}"
    [ ! -f "$voice_file" ] && voice_file=""
  fi

  echo "=== ${tc}: ${TC_NAME[$tc]} ==="
  TC_PASS=0

  for run in $(seq 1 $K); do
    echo "  run $run/$K..."

    if [ "$SKIP_EXERCISE" = true ]; then
      cached="${RESULTS_DIR}/${tc}/run-${run}.txt"
      if [ ! -f "$cached" ]; then
        echo "    cached output not found: $cached" >&2
        continue
      fi
      output_text=$(cat "$cached")
    else
      output_text=$(exercise_one "$input_file" "${TC_MODE[$tc]}" "$voice_file" "$run") || continue
      mkdir -p "${RESULTS_DIR}/${tc}"
      echo "$output_text" > "${RESULTS_DIR}/${tc}/run-${run}.txt"
    fi

    judge_result=$(judge_output "$tc" "$input_text" "$output_text") || judge_result='{"result":"fail","reason":"judge error","confidence":0.0}'

    result=$(echo "$judge_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('result','fail'))" 2>/dev/null || echo "fail")
    confidence=$(echo "$judge_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('confidence',0.0))" 2>/dev/null || echo "0.0")
    reason=$(echo "$judge_result" | python3 -c "import sys,json; print(json.load(sys.stdin).get('reason',''))" 2>/dev/null || echo "")

    if [ "$result" = "pass" ]; then
      TC_PASS=$((TC_PASS + 1))
    fi

    python3 -c "
import json
log = open('${SESSION_LOG}', 'a')
log.write(json.dumps({
  'type': 'case-run',
  'session': '${SESSION}',
  'test': '${tc}',
  'run': ${run},
  'k': ${K},
  'result': '${result}',
  'confidence': ${confidence},
  'reason': '''${reason}''',
  'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
}) + '\n')
log.close()
"

    echo "    result: $result (confidence: $confidence)"
  done

  PASS_K=$(python3 -c "
p = ${TC_PASS} / ${K}
print(round(p ** ${K}, 4))
")
  PASS_AT_K=$(python3 -c "
p = ${TC_PASS} / ${K}
print(round(1 - (1 - p) ** ${K}, 4))
")

  echo "  pass: $TC_PASS/$K, pass^k: $PASS_K, pass@k: $PASS_AT_K"

  python3 -c "
import json
log = open('${SESSION_LOG}', 'a')
log.write(json.dumps({
  'type': 'case-summary',
  'session': '${SESSION}',
  'test': '${tc}',
  'commit': '${COMMIT}',
  'k': ${K},
  'pass': ${TC_PASS},
  'pass@k': ${PASS_AT_K},
  'pass^k': ${PASS_K},
  'threshold': ${THRESHOLD},
  'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
}) + '\n')
log.close()
"

  THRESHOLD_PASS=$(python3 -c "import math; print(math.ceil($THRESHOLD * $K))")
  if [ "$TC_PASS" -ge "$THRESHOLD_PASS" ]; then
    TOTAL_PASS=$((TOTAL_PASS + 1))
  fi

  echo ""
done

DURATION_END=$(date +%s)
DURATION_SEC=$((DURATION_END - DURATION_START))
SUITE_PASS_BOOL="False"
[ "$TOTAL_PASS" -ge "$TOTAL_CASES" ] && SUITE_PASS_BOOL="True"

python3 -c "
import json
log = open('${SESSION_LOG}', 'a')
log.write(json.dumps({
  'type': 'session-end',
  'session': '${SESSION}',
  'total_cases': ${TOTAL_CASES},
  'total_pass': ${TOTAL_PASS},
  'suite_pass': ${SUITE_PASS_BOOL},
  'duration_sec': ${DURATION_SEC},
  'timestamp': '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
}) + '\n')
log.close()
"

echo "=========================================="
echo "  Evaluation Summary"
echo "=========================================="
echo "  Session:    $SESSION"
echo "  Commit:     $COMMIT"
echo "  k:          $K"
echo "  Threshold:  $THRESHOLD"
echo "  Duration:   ${DURATION_SEC}s"
echo "  Cases:      $TOTAL_PASS/$TOTAL_CASES passed"
echo "  Suite:      $([ "$SUITE_PASS_BOOL" = "True" ] && echo 'PASS' || echo 'FAIL')"
echo "  Log:        $SESSION_LOG"
echo "=========================================="

ln -sf "${SESSION}.jsonl" "${LOGS_DIR}/${COMMIT}-default.jsonl" 2>/dev/null || true

if [ "$SUITE_PASS_BOOL" = "False" ]; then
  exit 1
fi
