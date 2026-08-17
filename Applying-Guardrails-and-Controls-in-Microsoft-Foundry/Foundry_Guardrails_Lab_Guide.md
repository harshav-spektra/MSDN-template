# Applying Guardrails and Controls in Microsoft Foundry

### Estimated Duration: 60 Minutes

## 📘 Scenario

Contoso Retail is rolling out a customer-facing AI assistant built on a model deployed in Microsoft Foundry. Before the assistant goes live, the platform team must ensure it cannot be tricked into producing hateful, sexual, violent, or self-harm-related content — while still answering legitimate customer questions without being needlessly blocked. Microsoft Foundry's **Guardrails and controls** let the team define exactly what to detect, where to detect it, and what to do when it's found, without writing any moderation code of their own.

In this lab, you will act as the platform engineer responsible for configuring these guardrails: you'll inspect the built-in default guardrail, build a custom one from scratch, attach it to a model deployment, and prove — with real test prompts — that it behaves the way you configured it to.

## 📖 Overview

Microsoft Foundry guardrails are built from **controls**. Each control ties together three things: a **risk** to detect (such as Hate or Violence), an **intervention point** describing where in the request/response flow to look (user input or model output), and an **action** to take when the risk is found (Annotate, or Annotate and block). A **guardrail** is simply a named collection of these controls, and it's the guardrail — not the individual control — that gets applied to a model deployment or agent.

Every new Foundry resource ships with a default guardrail, **Microsoft.DefaultV2**, already applied to new deployments. In this lab, you'll first see what it protects against out of the box, then build your own guardrail with custom severity thresholds, apply it to your deployment, and use the Foundry playground to confirm the guardrail intervenes exactly where and how you configured it — before tuning it to reduce false positives.

## 🎯 Objectives

In this lab, you will complete the following modules:

- Module 0: Introduction & Environment Setup
- Module 1: Exploring the Default Guardrail
- Module 2: Creating & Configuring a Custom Guardrail
- Module 3: Testing the Guardrail
- Module 4: Troubleshooting & Best Practices
- Module 5: Wrap-Up & Next Steps

By the end of this lab, you will be able to:

- Explain what a guardrail is and how controls, risks, intervention points, and actions relate.
- Inspect the default Microsoft.DefaultV2 guardrail and its controls.
- Create a custom guardrail and configure risk controls and severity thresholds.
- Apply the guardrail to a model deployment and validate behavior with test prompts.
- Distinguish the Annotate vs. Annotate-and-block actions and tune severity to reduce false positives.

---

## Module 0: Introduction & Environment Setup

### Estimated Duration: 10 Minutes

In this module, you will confirm your lab environment meets every prerequisite before you touch a single guardrail setting, and you'll learn the four concepts that everything else in this lab builds on.

### Task 1: Understand the Core Concepts

Before configuring anything, make sure you can explain these four terms — every later module refers back to them.

| Concept | What it means |
|---|---|
| **Risk** | The category of harmful content a control watches for: **Hate**, **Sexual**, **Self-harm**, or **Violence**. |
| **Intervention point** | Where in the flow the check happens: **user input** (the prompt sent to the model) or **output** (the content the model generates back). |
| **Severity threshold** | The sensitivity level for a risk — **Low**, **Medium**, or **High** — that determines how aggressively content is flagged. |
| **Action** | What happens when the threshold is met: **Annotate** (flag the content and return metadata about it, but let it through) or **Annotate and block** (flag it *and* stop the response). |

1. Read through the table above and note that a **control** is the combination of exactly one risk, one or more intervention points, one severity threshold, and one action.

1. Understand that a **guardrail** is a named collection of controls — for example, a guardrail called `ContosoRetailGuardrail` might contain four controls, one for each risk category.

   > **Note:** Content detected at the **Safe** severity level is always labeled in annotations, but it is never filtered and is not configurable — there's nothing to "turn off" for safe content.

### Task 2: Verify Prerequisites

In this task, you will confirm your subscription, project, and permissions are ready before starting Module 1.

1. Confirm you have an active **Azure subscription** and can sign in to the [Microsoft Foundry portal](https://ai.azure.com).

1. Confirm a **Microsoft Foundry project** has already been provisioned for this lab, and that you can see it on the Foundry landing page.

   ![](./Images/GRD011.png)

1. Confirm the project has **at least one model deployment**. In the left navigation pane, select **Models + endpoints** and verify a deployment (for example, `gpt-4o`) is listed with a status of **Succeeded**.

   ![](./Images/GRD012.png)

1. Confirm your account has the **Foundry Account Owner** role (or **Foundry Owner**) on the Foundry resource. This is required to create and edit guardrails — without it, the **Guardrails + controls** page will be visible but read-only.

   > **Note:** Foundry's RBAC roles were recently renamed. If your portal or documentation still shows **Azure AI Account Owner** / **Azure AI Owner**, these are the same roles under their previous names — the underlying permissions are unchanged.

1. If you're unsure which role you hold, go to your Foundry resource in the **Azure portal** → **Access control (IAM)** → **Check access**, and search for your account.

   ![](./Images/GRD013.png)

---

## Module 1: Exploring the Default Guardrail

### Estimated Duration: 10 Minutes

In this module, you will locate the guardrails experience in the Foundry portal and inspect the guardrail that's already protecting your deployment.

### Task 1: Locate Guardrails in the Foundry Portal

1. In the [Microsoft Foundry portal](https://ai.azure.com), open your lab project.

1. In the left navigation pane, select **Guardrails + controls**.

   ![](./Images/GRD111.png)

1. Review the two tabs available on this page: **Content filters** (the classic, deployment-scoped filtering configuration) and **Guardrails** (the newer, named-policy model this lab focuses on). Select the **Guardrails** tab.

   ![](./Images/GRD112.png)

### Task 2: Review the Microsoft.DefaultV2 Guardrail

1. In the guardrails list, locate and select **Microsoft.DefaultV2** — the built-in guardrail automatically applied to new deployments.

   ![](./Images/GRD121.png)

1. Open the guardrail and review its list of controls. Note that it already contains one control per core content risk: **Hate**, **Sexual**, **Self-harm**, and **Violence**.

1. For each control, observe the three properties you learned in Module 0: its **intervention point(s)**, its **severity threshold**, and its **action**.

   > **Important:** Microsoft.DefaultV2 is **not editable**. If your organization needs different thresholds or actions, you must create a **custom guardrail** — which is exactly what you'll do in Module 2.

### Task 3: Map Risk Categories to Intervention Points

1. For each of the four risk categories in Microsoft.DefaultV2, confirm whether it is scanning **user input**, **output**, or **both**.

1. Note that Foundry guardrails support four possible intervention points in total: **user input**, **tool call** (preview), **tool response** (preview), and **output**. Core model guardrails in this lab use only user input and output; the tool-call and tool-response points apply to **agents** and are covered conceptually only, per this lab's scope.

1. Reflect on why scanning both input *and* output matters: a control on input catches a user trying to elicit harmful content, while a control on output catches harmful content the model generates even from an innocuous prompt.

---

## Module 2: Creating & Configuring a Custom Guardrail

### Estimated Duration: 20 Minutes

In this module, you will build a custom guardrail from scratch, add controls for all four core content risks, tune their severity thresholds, and apply the finished guardrail to your model deployment.

### Task 1: Create a New Guardrail

1. From the **Guardrails + controls** page, select the **Guardrails** tab, then select **+ Create guardrail**.

   ![](./Images/GRD211.png)

1. On the **Basic information** page, enter a descriptive name, for example `ContosoRetailGuardrail`, and select **Next**.

   ![](./Images/GRD212.png)

### Task 2: Add Controls for Content Risks

1. Select **+ Add control** to begin configuring your first risk.

1. Add a control for the **Hate** risk category.

1. Repeat the process to add three more controls, one each for **Sexual**, **Self-harm**, and **Violence** — so your guardrail has four controls in total, matching the core risks in scope for this lab.

   ![](./Images/GRD221.png)

   > **Note:** Agent-only risks (such as Prompt Shields for tool-call and tool-response intervention points) are visible in the control list but are out of scope for this lab, since we're applying this guardrail to a **model**, not an agent.

### Task 3: Set Severity Thresholds

1. For the **Hate** control, use the severity slider to set the threshold to **Medium**. This means content classified at Medium severity *or higher* will trigger the control.

1. Set the **Sexual** control's threshold to **Medium**.

1. Set the **Self-harm** control's threshold to **Low** — a stricter setting appropriate for a customer-facing retail assistant where self-harm content should almost never be tolerated.

1. Set the **Violence** control's threshold to **Medium**.

   ![](./Images/GRD231.png)

   > **Important:** A **lower** severity threshold is stricter — it catches more content, including borderline cases — while a **higher** threshold only catches the most severe content. Start restrictive, and relax thresholds later only after confirming the impact on legitimate traffic, which you'll practice in Module 3.

### Task 4: Configure Intervention Points

1. For each of the four controls, configure the intervention point to scan **both user input and output** — the input side stops a user from prompting for harmful content, and the output side catches harmful content the model might still generate.

   ![](./Images/GRD241.png)

### Task 5: Choose the Response Action

1. For all four controls, set the action to **Annotate and block** for this first pass — you want the guardrail to actively stop flagged content, not just flag it, so its blocking behavior is easy to observe in Module 3.

   > **Note:** **Annotate** returns metadata describing what was detected without stopping the response — useful for monitoring or gradual rollout. **Annotate and block** does both: it returns the same metadata *and* prevents the flagged content from reaching the user. You'll compare these two directly in Module 3.

1. Select **Next**, review your configuration on the summary page, and select **Create** to save the guardrail.

   ![](./Images/GRD251.png)

### Task 6: Apply the Guardrail to a Model Deployment

1. From your new guardrail's details page, select **Apply to deployment**.

1. Choose your lab's model deployment (for example, `gpt-4o`) from the list, and confirm the assignment.

   ![](./Images/GRD261.png)

1. Navigate to **Models + endpoints**, select your deployment, and confirm that `ContosoRetailGuardrail` now appears as the guardrail assigned to it, replacing Microsoft.DefaultV2.

   ![](./Images/GRD262.png)

   > **Note:** A guardrail can be applied to multiple deployments and agents at once, and a deployment can only have one guardrail active at a time — applying a new one replaces the previous assignment.

---

## Module 3: Testing the Guardrail

### Estimated Duration: 12 Minutes

In this module, you will use the Foundry portal's chat playground to send prompts against your deployment and observe exactly how your guardrail responds.

### Task 1: Establish a Baseline with Benign Prompts

1. In the left navigation pane, select **Playgrounds**, then open the **Chat playground** against your guarded deployment.

   ![](./Images/GRD311.png)

1. Send a clearly benign prompt, for example: *"What are your store's return policy hours?"* Confirm the response is returned normally, with no annotation or blocking.

   ![](./Images/GRD312.png)

1. This benign response is your **baseline** — the expected, unaffected behavior your guardrail should preserve for legitimate traffic.

### Task 2: Send Prompts That Trigger Detection

1. Send a prompt designed to trigger the **Violence** control at a Medium-or-higher severity level.

1. Observe the response: because the action is **Annotate and block**, the model's completion is withheld and the playground surfaces the **annotation** describing which risk category and severity level were detected.

   ![](./Images/GRD321.png)

1. Repeat with a prompt targeting the **Hate** category, and again inspect the returned annotation.

   > **Note:** Annotations are returned for every configured category on every request, whether or not that category was actually triggered — this is what lets you audit borderline content even when nothing was blocked.

### Task 3: Observe Blocking Behavior at Different Severity Levels

1. Return to your guardrail's configuration and temporarily raise the **Violence** control's threshold from Medium to **High**.

1. Re-send the same prompt from Task 2. Observe that the same content that was previously blocked at Medium may now pass through unblocked, since it doesn't meet the stricter High-severity bar.

   ![](./Images/GRD331.png)

1. Set the threshold back to **Medium** before continuing.

### Task 4: Adjust a Threshold and Re-Test

1. Change the **Self-harm** control's action from **Annotate and block** to **Annotate** only.

1. Re-send a prompt that previously triggered the Self-harm control. Confirm that this time, the model's response is *not* withheld — but the annotation still reports that Self-harm content was detected.

   ![](./Images/GRD341.png)

1. Compare this result to Task 2's Violence test: this is the practical difference between **Annotate** and **Annotate and block** — one observes, the other intervenes.

---

## Module 4: Troubleshooting & Best Practices

### Estimated Duration: 5 Minutes

In this module, you will review common reasons a guardrail doesn't behave as expected, and the best practices Microsoft recommends for tuning guardrails in production.

### Task 1: Diagnose "Guardrail Not Applying" or Unexpected Flagging

Work through this checklist any time a guardrail doesn't seem to be taking effect:

1. **Confirm the guardrail is actually assigned** to the deployment (or agent) your application is calling — not just created. Revisit Module 2, Task 6 to re-verify the assignment.

1. **Remember the override rule for agents:** if an agent is involved, the **agent's guardrail overrides the model's guardrail**. A correctly configured model-level guardrail has no effect if the agent calling that model has its own guardrail assigned.

1. **Check whether the action is set to Annotate only.** Content that's merely flagged — not blocked — will still reach the user. This is expected behavior, not a bug, if the control's action is Annotate.

1. **Verify Microsoft.DefaultV2 hasn't been assumed to be "modified."** It's a fixed, non-editable guardrail — if you need different behavior, you must apply a custom guardrail like the one you built in Module 2, not attempt to edit the default.

1. **For "No filters" or fully custom severity control:** these require your tenant to be approved for **modified content filtering** through Microsoft's Limited Access Review process. Without that approval, only the standard Low / Medium / High threshold combinations are available.

### Task 2: Tune Severity to Balance Safety and False Positives

1. Apply Microsoft's recommended approach: **start restrictive, then relax** — begin with lower (stricter) severity thresholds, and only raise them after confirming the impact on real traffic, exactly as you practiced in Module 3, Task 3.

1. **Measure after every change** — re-run your baseline and trigger prompts any time you adjust a threshold or action, so you can confirm the change had the intended effect and didn't introduce new false positives or negatives.

1. **Monitor latency.** Guardrail processing adds approximately **50–100 ms per intervention point**. For high-throughput scenarios, start with only the essential controls and watch your latency metrics before adding more.

1. For deeper tuning guidance, remember that annotations are returned even for non-blocking controls — use them to see everything the guardrail is detecting, not just what it's actively blocking, before deciding whether a threshold needs adjustment.

---

## Module 5: Wrap-Up & Next Steps

### Estimated Duration: 3 Minutes

In this module, you will clean up the resources you created and review where to go next.

### Task 1: Clean Up Resources

1. If this guardrail was created solely for this lab, return to **Guardrails + controls** → **Guardrails**, select `ContosoRetailGuardrail`, and remove its assignment from the model deployment.

1. Optionally, delete the custom guardrail itself if it won't be reused, to keep your project's guardrail list clean for future labs.

   ![](./Images/GRD511.png)

### Task 2: Summary and Further Reading

In this lab, you explored how Microsoft Foundry guardrails protect model deployments from harmful content. You started by inspecting the built-in **Microsoft.DefaultV2** guardrail to understand its default controls, then created a custom guardrail — `ContosoRetailGuardrail` — with controls for Hate, Sexual, Self-harm, and Violence risks, each configured with its own severity threshold and intervention points. You applied that guardrail to a model deployment and used the chat playground to validate its behavior with real prompts, directly comparing the **Annotate** and **Annotate and block** actions and observing how severity thresholds change what gets flagged. Finally, you reviewed the troubleshooting checklist and best practices — starting restrictive, measuring after every change, and watching latency — that Microsoft recommends for tuning guardrails in production.

For further reading:

- [Guardrails and controls overview in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/guardrails/guardrails-overview)
- [How to configure guardrails and controls in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/guardrails/how-to-create-guardrails)
- [Harm categories and severity levels in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/content-filter-severity-levels)
- [Role-based access control for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/concepts/rbac-foundry)

You have successfully completed this lab.
