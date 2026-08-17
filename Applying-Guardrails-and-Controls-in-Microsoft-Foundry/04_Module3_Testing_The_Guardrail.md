Module 3: Testing the Guardrail
Estimated Duration: 12 Minutes

## Scenario

A guardrail configuration that has never been tested is just a guess. Before Contoso's platform team can tell leadership the assistant is safe to launch, they need proof: real prompts, sent against the real deployment, showing exactly what gets through, what gets blocked, and why. That proof is what this module produces.

## Overview

In this module, you will use the Foundry chat playground to send prompts against your guarded deployment and observe exactly how `ContosoRetailGuardrail` responds. You will establish a benign baseline, trigger a real detection, compare behavior across different severity thresholds, and finish by directly comparing the Annotate and Annotate-and-block actions on the same risk category.

## Objectives

- Task 1: Establish a baseline with benign prompts
- Task 2: Send prompts that trigger detection and inspect annotations
- Task 3: Observe blocking behavior at different severity levels
- Task 4: Adjust a threshold and re-test to compare results

## Task 1: Establish a baseline with benign prompts

In this task, you will confirm that ordinary customer questions pass through your guardrail unaffected.

1. In the left navigation pane, select **Playgrounds**, then open the **Chat playground** against your guarded deployment.

1. Send a clearly benign prompt, for example:

   *"What are your store's return policy hours?"*

1. Confirm the response is returned normally, with no annotation or blocking.

1. Record this as your **baseline** — the expected, unaffected behavior your guardrail must preserve for legitimate traffic throughout the rest of this module.

   | Test | Prompt type | Expected result | Actual result |
   |---|---|---|---|
   | Baseline | Benign customer question | Response returned normally | |

## Task 2: Send prompts that trigger detection and inspect annotations

In this task, you will confirm your guardrail actually intervenes when it should.

1. Send a prompt designed to trigger the **Violence** control at a Medium-or-higher severity level.

1. Observe the response. Because the action is **Annotate and block**, the model's completion is withheld, and the playground surfaces the **annotation** describing which risk category and severity level were detected.

1. Repeat with a prompt targeting the **Hate** category, and again inspect the returned annotation.

1. Record your results:

   | Test | Risk targeted | Action configured | Response withheld? | Annotation shown? |
   |---|---|---|---|---|
   | 1 | Violence | Annotate and block | | |
   | 2 | Hate | Annotate and block | | |

   > **Note:** Annotations are returned for **every** configured category on every request, whether or not that category was actually triggered. This is what lets Contoso's team audit borderline content even when nothing was blocked — the annotation is not limited to only the risk that fired.

## Task 3: Observe blocking behavior at different severity levels

In this task, you will confirm that the severity threshold — not just the risk category — determines whether content is blocked.

1. Return to your guardrail's configuration and temporarily raise the **Violence** control's threshold from **Medium** to **High**.

1. Re-send the same prompt from Task 2. Observe whether the same content that was previously blocked at Medium now passes through unblocked, since it may no longer meet the stricter High-severity bar.

1. Record your comparison:

   | Threshold tested | Same prompt as Task 2 | Blocked? |
   |---|---|---|
   | Medium | Violence prompt | |
   | High | Violence prompt | |

1. Set the **Violence** threshold back to **Medium** before continuing to Task 4, so your guardrail matches the configuration from Module 2.

   > **Important:** This is the practical meaning of "start restrictive, then relax" from Module 2, Task 3 — moving a threshold from Medium to High measurably changes what gets through, so every threshold change should be re-tested exactly like you just did, never assumed.

## Task 4: Adjust a threshold and re-test to compare results

In this task, you will directly compare the Annotate and Annotate-and-block actions on the same risk category.

1. Change the **Self-harm** control's action from **Annotate and block** to **Annotate** only. Leave its severity threshold at **Low**.

1. Re-send a prompt that previously triggered the Self-harm control (or a similar one, if you did not test Self-harm directly in Task 2).

1. Confirm that this time, the model's response is **not** withheld — but the annotation still reports that Self-harm content was detected at the configured threshold.

1. Record your final comparison for the module:

   | Control | Action | Response withheld? | Annotation still shown? |
   |---|---|---|---|
   | Violence (Task 2) | Annotate and block | | |
   | Self-harm (Task 4) | Annotate only | | |

1. Change the **Self-harm** control's action back to **Annotate and block**, restoring the configuration from Module 2, before moving on to Module 4.

## Summary

In this module, you proved `ContosoRetailGuardrail` works exactly as designed. You confirmed a benign baseline passes through untouched, triggered real detections against the Hate and Violence controls and inspected their annotations, watched the same prompt pass or block depending on the severity threshold, and directly compared the Annotate and Annotate-and-block actions on the same risk category. You now have concrete evidence — not just a configuration — that the guardrail behaves as intended.

Click **Next** from the bottom right corner to continue to Module 4.
