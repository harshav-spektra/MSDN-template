Module 2: Creating & Configuring a Custom Guardrail
Estimated Duration: 20 Minutes

## Scenario

Microsoft.DefaultV2 gives Contoso's deployment a baseline of protection, but the platform team has a specific requirement the default can't satisfy: for a retail assistant that any customer can reach, self-harm content should be caught far more aggressively than the other risk categories, and every detection needs to actively block the response rather than just flag it. That means Contoso needs its own guardrail.

## Overview

In this module, you will build a custom guardrail named `ContosoRetailGuardrail` from scratch. You will add one control for each of the four core content risks, set a severity threshold for each, configure both intervention points, choose a response action, and finally apply the finished guardrail to your model deployment — replacing Microsoft.DefaultV2.

## Objectives

- Task 1: Create a new guardrail in the project
- Task 2: Add controls for content risks
- Task 3: Set severity thresholds
- Task 4: Configure intervention points
- Task 5: Choose the response action
- Task 6: Apply the guardrail to a model deployment

## Task 1: Create a new guardrail in the project

In this task, you will start a new guardrail and give it a name.

1. From the **Guardrails + controls** page, select the **Guardrails** tab.

1. Select **+ Create guardrail**.

1. On the **Basic information** page, enter the name `ContosoRetailGuardrail`.

1. Select **Next** to move to control configuration.

## Task 2: Add controls for content risks

In this task, you will add one control for each of the four core content risks in scope for this lab.

1. Select **+ Add control** to begin configuring your first risk.

1. Add a control for the **Hate** risk category.

1. Select **+ Add control** again and add a control for **Sexual**.

1. Repeat twice more to add controls for **Self-harm** and **Violence**.

1. Confirm your guardrail now lists four controls in total:

   | # | Risk |
   |---|---|
   | 1 | Hate |
   | 2 | Sexual |
   | 3 | Self-harm |
   | 4 | Violence |

   > **Note:** Additional agent-only risks (such as Prompt Shields for the tool-call and tool-response intervention points) may be visible in the control picker. These are out of scope for this lab, since you are applying this guardrail to a **model**, not an agent — do not add them.

## Task 3: Set severity thresholds

In this task, you will set a severity threshold for each of the four controls, reflecting Contoso's requirement that self-harm content be caught more aggressively than the others.

1. Recall from Module 0, Task 2 that a **lower** threshold is stricter — it catches more content, including borderline cases — while a **higher** threshold only catches the most severe content.

1. Configure each control's threshold as follows:

   | Risk | Severity threshold | Rationale |
   |---|---|---|
   | Hate | Medium | Balanced default for general customer traffic |
   | Sexual | Medium | Balanced default for general customer traffic |
   | Self-harm | **Low** | Stricter setting appropriate for a public-facing retail assistant, where self-harm content should almost never be tolerated |
   | Violence | Medium | Balanced default for general customer traffic |

1. Use the severity slider on each control to set the threshold values from the table above.

1. Compare this configuration to the reasoning you wrote in Module 0, Task 2. Note any differences between your original instinct and Contoso's actual requirement.

   > **Important:** Start restrictive, then relax. Microsoft's guidance is to begin with higher (stricter) severity thresholds and adjust downward only after confirming acceptable behavior with real traffic — you will practice this adjustment directly in Module 3, Task 3.

## Task 4: Configure intervention points

In this task, you will set where each control evaluates content.

1. For **all four controls**, configure the intervention point to scan **both user input and output**.

1. Confirm your configuration matches the following:

   | Risk | User input | Output |
   |---|---|---|
   | Hate | ✔ | ✔ |
   | Sexual | ✔ | ✔ |
   | Self-harm | ✔ | ✔ |
   | Violence | ✔ | ✔ |

1. Recall from Module 1, Task 3 why both intervention points matter: input-side scanning stops a user from prompting for harmful content directly, while output-side scanning catches harmful content the model might still generate.

## Task 5: Choose the response action

In this task, you will set what happens when a control's threshold is met.

1. For **all four controls**, set the action to **Annotate and block**.

1. Confirm your full configuration before saving:

   | Risk | Severity | Input | Output | Action |
   |---|---|---|---|---|
   | Hate | Medium | ✔ | ✔ | Annotate and block |
   | Sexual | Medium | ✔ | ✔ | Annotate and block |
   | Self-harm | Low | ✔ | ✔ | Annotate and block |
   | Violence | Medium | ✔ | ✔ | Annotate and block |

   > **Note:** You are deliberately setting every control to **Annotate and block** for this first pass, so its behavior is easy to observe and prove out in Module 3. You will change one control's action to **Annotate** only later in Module 3, Task 4, to compare the two actions directly.

1. Select **Next**, review your configuration on the summary page, and select **Create** to save the guardrail.

## Task 6: Apply the guardrail to a model deployment

In this task, you will attach your new guardrail to Contoso's model deployment, replacing Microsoft.DefaultV2.

1. From your new guardrail's details page, select **Apply to deployment**.

1. Choose your lab's model deployment (for example, `gpt-4o`) from the list, and confirm the assignment.

1. Navigate to **Models + endpoints**, select your deployment, and confirm that `ContosoRetailGuardrail` now appears as the guardrail assigned to it, in place of Microsoft.DefaultV2.

1. Record the following in your notes for use in later modules:

   - Guardrail name: `ContosoRetailGuardrail`
   - Deployment it's applied to:
   - Confirmed replacing Microsoft.DefaultV2: Yes / No

   > **Note:** A guardrail can be applied to multiple deployments and agents at once, but a deployment can only have **one guardrail active at a time** — applying a new one always replaces the previous assignment, exactly as you just did.

## Summary

In this module, you built `ContosoRetailGuardrail` from scratch: four controls covering Hate, Sexual, Self-harm, and Violence, each with its own severity threshold, both intervention points enabled, and the Annotate-and-block action selected across the board — with Self-harm deliberately set stricter than the rest to reflect Contoso's public-facing risk tolerance. You then applied the guardrail to your model deployment, replacing Microsoft.DefaultV2. Your deployment is now protected by a configuration you designed and built yourself.

Click **Next** from the bottom right corner to continue to Module 3.
