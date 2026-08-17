Module 0: Introduction & Environment Setup
Estimated Duration: 10 Minutes

## Scenario

Before you touch a single guardrail setting, Contoso's platform team needs every engineer on the project to speak the same language. A guardrail is built from a small number of concepts — risk, intervention point, severity, and action — and every later module in this lab refers straight back to them. You also need to confirm your lab environment is actually ready: the right role, an existing project, and a live model deployment to protect.

## Overview

In this module, you will learn the four building blocks that make up every Foundry guardrail control, see how those blocks combine into a guardrail, and then verify your lab environment's prerequisites — subscription access, project availability, an existing model deployment, and your RBAC role — before moving on to Module 1.

## Objectives

- Task 1: Understand the core guardrail concepts
- Task 2: Understand how controls combine into a guardrail
- Task 3: Verify prerequisites

## Task 1: Understand the core guardrail concepts

In this task, you will learn the four properties that define every guardrail control.

1. Read the definitions below. You will use this exact vocabulary in every remaining module.

   | Concept | What it means | Example values |
   |---|---|---|
   | **Risk** | The category of harmful content a control watches for | Hate, Sexual, Self-harm, Violence |
   | **Intervention point** | Where in the flow the check happens | User input, Output (Tool call and Tool response are agent-only, Preview) |
   | **Severity threshold** | How sensitive the detection is | Low, Medium, High |
   | **Action** | What happens when the threshold is met | Annotate, Annotate and block |

1. Note that content classified at the **Safe** severity level is always recorded in annotations, but it is never filtered and is not configurable — there is nothing to "turn off" for safe content.

1. Note the difference between the two actions:

   - **Annotate** — the request is flagged and metadata about the detection is returned, but the response still reaches the caller.
   - **Annotate and block** — the request is flagged **and** the response is withheld from the caller.

1. Write a one-sentence definition of a **control** in your own words. It should mention all four properties from the table above.

   Example format:

   *A control is a rule that checks for one risk category, at one or more intervention points, using one severity threshold, and takes one action when triggered.*

## Task 2: Understand how controls combine into a guardrail

In this task, you will learn how individual controls come together, and where a guardrail fits into the bigger picture.

1. Understand that a **guardrail** is simply a named collection of controls. For example, a guardrail named `ContosoRetailGuardrail` could contain four controls — one for each of the four core content risks.

1. Understand that it is the **guardrail**, not the individual control, that gets applied to a model deployment or an agent.

1. Understand that a deployment can only have **one guardrail active at a time** — applying a new guardrail to a deployment replaces whichever guardrail was previously assigned.

1. Understand that a single guardrail can be applied to **multiple deployments and agents** at once, which is why Contoso's platform team can build one guardrail and reuse it across every customer-facing deployment.

1. Complete this short mapping exercise in your notes — for each control property, write down which of the four core risks (Hate, Sexual, Self-harm, Violence) you think should use the **strictest** (Low) severity threshold for a retail customer assistant, and why. You will build this configuration for real in Module 2.

   > **Note:** There's no single correct answer here — this is a design decision every organization makes based on its own risk tolerance and audience. You will revisit your reasoning in Module 2, Task 3.

## Task 3: Verify prerequisites

In this task, you will confirm your subscription, project, deployment, and permissions are all ready before starting Module 1.

1. Confirm you have an active **Azure subscription** and can sign in to the [Microsoft Foundry portal](https://ai.azure.com) using the credentials provided in your lab's Environment tab.

1. Confirm a **Microsoft Foundry project** has already been provisioned for this lab. On the Foundry landing page, verify you can see and open this project.

1. Confirm the project has **at least one model deployment**. In the left navigation pane, select **Models + endpoints** and verify a deployment (for example, `gpt-4o`) is listed with a status of **Succeeded**.

   | Item to verify | Expected result | Your result |
   |---|---|---|
   | Sign-in to Foundry portal | Successful | |
   | Project visible and accessible | Yes | |
   | Model deployment present | Status: Succeeded | |
   | RBAC role confirmed | Foundry Account Owner or Foundry Owner | |

1. Confirm your account has the **Foundry Account Owner** role (or **Foundry Owner**) on the Foundry resource. This role is required to create and edit guardrails — without it, the **Guardrails + controls** page will be visible but read-only.

   > **Note:** Foundry's RBAC roles were recently renamed. If your portal or documentation still shows **Azure AI Account Owner** / **Azure AI Owner**, these are the same roles under their previous names — the role IDs and underlying permissions are unchanged.

1. If you are unsure which role you hold, go to your Foundry resource in the **Azure portal** → **Access control (IAM)** → **Check access**, and search for your account to confirm your assigned role.

1. Record the following in your notes, since you will reference them throughout the remaining modules:

   - Foundry project name:
   - Model deployment name:
   - Confirmed RBAC role:

## Summary

In this module, you learned the four core concepts behind every Foundry guardrail control — risk, intervention point, severity threshold, and action — and how those controls combine into a named guardrail that gets applied to a deployment. You then verified that your lab environment has an accessible Foundry project, an existing model deployment, and the Foundry Account Owner role required to build and apply guardrails. You are now ready to inspect the guardrail already protecting your deployment.

Click **Next** from the bottom right corner to continue to Module 1.
