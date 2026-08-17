Module 1: Exploring the Default Guardrail
Estimated Duration: 10 Minutes

## Scenario

Contoso's model deployment is not unprotected today — every new Foundry deployment is automatically covered by a built-in guardrail the moment it's created. Before Contoso's platform team designs anything custom, they need to understand exactly what that default guardrail already does, and just as importantly, what it does *not* let them change.

## Overview

In this module, you will locate the Guardrails + controls experience in the Foundry portal, open the built-in **Microsoft.DefaultV2** guardrail, and inspect its controls one by one. You will finish by mapping each of its risk categories to the intervention points it scans, so you understand exactly what "default protection" means before you build something custom in Module 2.

## Objectives

- Task 1: Locate guardrails in the Microsoft Foundry portal
- Task 2: Review the Microsoft.DefaultV2 guardrail and its controls
- Task 3: Map risk categories to intervention points

## Task 1: Locate guardrails in the Microsoft Foundry portal

In this task, you will find the Guardrails + controls page and understand its two tabs.

1. In the [Microsoft Foundry portal](https://ai.azure.com), open your lab project.

1. In the left navigation pane, select **Guardrails + controls**.

1. Review the two tabs available on this page:

   | Tab | What it is | Scope |
   |---|---|---|
   | **Content filters** | The classic, deployment-scoped filtering configuration | Legacy / Foundry Models (classic) |
   | **Guardrails** | The newer, named-policy model | This lab's focus |

1. Select the **Guardrails** tab and confirm the page loads without error. If it appears read-only rather than editable, revisit Module 0, Task 3 to re-verify your RBAC role.

## Task 2: Review the Microsoft.DefaultV2 guardrail and its controls

In this task, you will open the built-in guardrail and record what it currently protects.

1. In the guardrails list, locate and select **Microsoft.DefaultV2** — the built-in guardrail automatically applied to every new deployment.

1. Open the guardrail and review its list of controls. Confirm it contains one control for each of the four core content risks:

   | Risk | Present in Microsoft.DefaultV2? | Intervention point(s) | Severity threshold | Action |
   |---|---|---|---|---|
   | Hate | | | | |
   | Sexual | | | | |
   | Self-harm | | | | |
   | Violence | | | | |

1. Fill in the table above directly from what you observe in the portal for each control.

1. Attempt to change one of the severity sliders on a Microsoft.DefaultV2 control. Confirm that the guardrail is **not editable** — this is expected and by design.

   > **Important:** Microsoft.DefaultV2 is fixed and cannot be modified. If Contoso needs different thresholds, intervention points, or actions, the platform team must create a **custom guardrail** — which is exactly what you will do in Module 2. A common troubleshooting mistake is assuming Microsoft.DefaultV2 has been edited when it actually cannot be; you will revisit this in Module 4.

## Task 3: Map risk categories to intervention points

In this task, you will confirm exactly where Microsoft.DefaultV2 is scanning content, and why that matters.

1. For each of the four risk categories you recorded in Task 2, confirm whether it scans **user input**, **output**, or **both**.

1. Understand that Foundry guardrails support four possible intervention points in total:

   | Intervention point | Applies to | In scope for this lab? |
   |---|---|---|
   | User input | Models and agents | Yes |
   | Output | Models and agents | Yes |
   | Tool call (Preview) | Agents only | Conceptual only |
   | Tool response (Preview) | Agents only | Conceptual only |

1. Since this lab applies guardrails to a **model deployment**, only the **user input** and **output** intervention points are relevant to the hands-on work in Module 2 and Module 3. Tool call and tool response exist for **agent** scenarios and are out of scope for hands-on configuration in this lab.

1. Write a one-sentence answer in your notes to the following: *why does scanning both input and output matter, rather than just one or the other?*

   Example format:

   *A control on input stops a user from prompting for harmful content directly, while a control on output catches harmful content the model might still generate even from an innocent-looking prompt.*

## Summary

In this module, you located the Guardrails + controls page in the Foundry portal and opened the built-in Microsoft.DefaultV2 guardrail. You recorded its four risk controls, their intervention points, severity thresholds, and actions, and confirmed that this default guardrail cannot be edited. You then mapped Foundry's four possible intervention points to what's actually in scope for a model deployment in this lab — user input and output. You now understand exactly what's protecting Contoso's deployment today, and why a custom guardrail is needed to change that behavior.

Click **Next** from the bottom right corner to continue to Module 2.
