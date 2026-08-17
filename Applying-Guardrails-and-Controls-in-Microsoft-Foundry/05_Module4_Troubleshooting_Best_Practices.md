Module 4: Troubleshooting & Best Practices
Estimated Duration: 5 Minutes

## Scenario

Guardrails don't stay static once they're live. Contoso's platform team will inevitably hit two situations after launch: someone reporting the guardrail "isn't working," and pressure to loosen a threshold that's flagging too much legitimate traffic. Both situations have a standard diagnostic path, and this module walks through it before Contoso closes out the lab.

## Overview

In this module, you will work through Microsoft's troubleshooting checklist for a guardrail that doesn't appear to be taking effect, and then apply Microsoft's recommended best practices for tuning severity thresholds to reduce false positives without reopening the door to real risk.

## Objectives

- Task 1: Diagnose "guardrail not applying" or unexpected flagging
- Task 2: Tune severity to balance safety and false positives

## Task 1: Diagnose "guardrail not applying" or unexpected flagging

In this task, you will work through the standard checklist any time a guardrail doesn't seem to behave as expected.

1. **Confirm the guardrail is actually assigned** to the deployment (or agent) the application is calling — not just created. Revisit Module 2, Task 6 to re-verify `ContosoRetailGuardrail` is still applied to your deployment.

1. **Remember the override rule for agents:** if an agent is involved anywhere in the flow, the **agent's guardrail overrides the model's guardrail**. A correctly configured model-level guardrail has no effect if the agent calling that model has its own guardrail assigned instead.

1. **Check whether the action is set to Annotate only.** Content that's merely flagged — not blocked — will still reach the user. This is expected behavior, not a bug, whenever a control's action is Annotate. You saw this directly in Module 3, Task 4.

1. **Verify Microsoft.DefaultV2 hasn't been assumed to be "modified."** As you confirmed in Module 1, Task 2, it is a fixed, non-editable guardrail. If different behavior is needed, a custom guardrail like `ContosoRetailGuardrail` must be applied instead of attempting to edit the default.

1. **For "No filters" or fully custom severity control:** these require the tenant to be approved for **modified content filtering** through Microsoft's Limited Access Review process. Without that approval, only the standard Low / Medium / High threshold combinations are available — attempting to disable filtering entirely will not work without this approval.

1. Complete this diagnostic checklist for your own deployment as a final confirmation before wrap-up:

   | Check | Status |
   |---|---|
   | Guardrail assigned to correct deployment | |
   | No agent overriding the model's guardrail | |
   | Action settings match intended behavior (Annotate vs. Annotate and block) | |
   | Microsoft.DefaultV2 not mistaken for an editable guardrail | |
   | Modified content filtering approval confirmed, if applicable | |

## Task 2: Tune severity to balance safety and false positives

In this task, you will apply Microsoft's recommended tuning practices to `ContosoRetailGuardrail`.

1. Apply Microsoft's recommended approach: **start restrictive, then relax** — begin with lower (stricter) severity thresholds, and only raise them after confirming the real-world impact, exactly as you practiced in Module 3, Task 3.

1. **Measure after every change.** Any time a threshold or action is adjusted, re-run a baseline prompt and a trigger prompt — as you did throughout Module 3 — to confirm the change had the intended effect and did not introduce new false positives or negatives.

1. **Monitor latency.** Guardrail processing adds approximately **50–100 ms per intervention point**. Since `ContosoRetailGuardrail` scans both user input and output for all four risks, budget for this added latency in any performance testing. For high-throughput scenarios, start with only the essential controls and watch latency metrics before adding more.

1. **Use annotations for tuning, not just auditing.** As you saw in Module 3, Task 2, annotations are returned for every configured category on every request — even ones that didn't trigger blocking. Review annotation data over time to see everything the guardrail is detecting, not only what it's actively blocking, before deciding whether a threshold needs adjustment.

1. Record one tuning decision Contoso's team should revisit after the assistant has been live for a few weeks, and why:

   Example format:

   *If the Hate control at Medium severity produces a high rate of false positives on legitimate product complaints, consider raising it to High and re-measuring — but only after confirming the volume and nature of the false positives with real traffic data, not assumption.*

## Summary

In this module, you worked through Microsoft's standard troubleshooting checklist for guardrails that appear not to be working — checking deployment assignment, the agent-override rule, action settings, the non-editable nature of Microsoft.DefaultV2, and modified-filtering approval requirements. You then applied Microsoft's best practices for ongoing tuning: starting restrictive, measuring after every change, watching latency, and using annotations as a tuning signal rather than only an audit trail. Contoso's platform team now has a repeatable process for keeping the guardrail effective after launch, not just at the moment it was configured.

Click **Next** from the bottom right corner to continue to Module 5.
