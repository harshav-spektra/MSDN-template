Applying Guardrails and Controls in Microsoft Foundry
Overall Estimated Duration: 1 Hour

## 📘 Lab Scenario

Contoso Retail, a national retail chain, is preparing to launch a customer-facing AI shopping assistant built on a model deployed in Microsoft Foundry. Before the assistant goes live, the platform team must guarantee that it cannot be manipulated into producing hateful, sexual, violent, or self-harm-related content — while still answering ordinary customer questions without being needlessly blocked.

Before deployment, Contoso must determine:

- What a guardrail actually protects against, and how it is built from controls
- How to configure risk categories, severity thresholds, and intervention points for its own use case
- How to apply a guardrail to a live model deployment
- How to prove — with real test prompts — that the guardrail behaves exactly as configured
- How to tune and troubleshoot the guardrail once it's running, to balance safety against false positives

Throughout this lab, you will inspect Foundry's built-in default guardrail, design and build a custom guardrail for Contoso's assistant, apply it to a model deployment, and validate it end-to-end in the Foundry playground.

## 📖 Lab Overview

This hands-on lab walks through the end-to-end process of understanding, configuring, applying, and validating guardrails for a model deployment in Microsoft Foundry.

The lab is divided into six modules:

**Module 0: Introduction & Environment Setup**
Learn the four building blocks of every guardrail — risks, intervention points, severity, and actions — and confirm your lab environment meets every prerequisite.

**Module 1: Exploring the Default Guardrail**
Locate the Guardrails + controls experience in the Foundry portal and inspect Microsoft.DefaultV2, the built-in guardrail already protecting your deployment.

**Module 2: Creating & Configuring a Custom Guardrail**
Build a custom guardrail from scratch for Contoso's assistant: add controls for all four core content risks, set severity thresholds, configure intervention points, choose a response action, and apply it to your model deployment.

**Module 3: Testing the Guardrail**
Use the Foundry chat playground to establish a benign baseline, trigger detections, compare severity levels, and directly compare the Annotate and Annotate-and-block actions.

**Module 4: Troubleshooting & Best Practices**
Work through Microsoft's troubleshooting checklist for guardrails that don't appear to be taking effect, and apply Microsoft's recommended tuning practices.

**Module 5: Wrap-Up & Next Steps**
Clean up the resources you created and review further reading.

## 🎯 Lab Objectives

By the end of this lab, you will be able to configure, apply, and validate a custom guardrail in Microsoft Foundry that protects a model deployment while minimizing false positives.

**Foundational Concepts**

- Explain what a guardrail is and how controls, risks, intervention points, and actions relate
- Identify the four core content risk categories: Hate, Sexual, Self-harm, and Violence
- Distinguish the two core intervention points used by model guardrails: user input and output

**Guardrail Configuration**

- Inspect the default Microsoft.DefaultV2 guardrail and its controls
- Create a custom guardrail and add controls for each content risk
- Configure severity thresholds (Low / Medium / High) per control
- Apply the guardrail to a model deployment

**Validation & Testing**

- Validate guardrail behavior with benign and risk-triggering test prompts
- Distinguish the Annotate vs. Annotate-and-block actions
- Compare detection behavior across different severity thresholds

**Operational Readiness**

- Diagnose common reasons a guardrail appears not to be working
- Apply Microsoft's best practices for tuning severity to reduce false positives
- Understand the latency impact of guardrail processing on a deployment

## ⚙️ Prerequisites

Before starting the lab, ensure you have:

**Knowledge Requirements:**

- Basic understanding of Microsoft Foundry and model deployments
- Familiarity with Azure fundamentals, including core cloud concepts
- Understanding of Azure role-based access control (RBAC) principles
- Awareness of responsible AI and content-safety concepts

**Environment Requirements:**

- An active Azure subscription
- A Microsoft Foundry project, pre-provisioned for this lab
- At least one model deployment already present in the project (for example, `gpt-4o`)
- The **Foundry Account Owner** role (or **Foundry Owner**) on the Foundry resource — required to create and edit guardrails

## 🏗️ Architecture

The Contoso Retail guardrails scenario is built around a single Microsoft Foundry project containing one model deployment. Requests flow from the Foundry chat playground (standing in for Contoso's future customer-facing assistant) into the model deployment. Before a prompt reaches the model, and again before the model's response reaches the caller, Foundry's guardrail engine intercepts the content and evaluates it against every control in the guardrail currently applied to that deployment.

### 🖼️ Architecture Diagram

```
 Customer / Test Prompt
          │
          ▼
 ┌─────────────────────────┐
 │   Foundry Playground     │
 └───────────┬──────────────┘
             │  user input
             ▼
 ┌─────────────────────────────────────┐
 │        Guardrail (applied)           │
 │  Controls: Hate · Sexual ·            │
 │  Self-harm · Violence                 │
 │  Intervention point: USER INPUT       │
 └───────────┬───────────────────────────┘
             │ passes / blocked / annotated
             ▼
 ┌─────────────────────────┐
 │     Model Deployment      │
 │        (gpt-4o)           │
 └───────────┬────────────────┘
             │ model response
             ▼
 ┌─────────────────────────────────────┐
 │        Guardrail (applied)           │
 │  Same controls, evaluated again       │
 │  Intervention point: OUTPUT           │
 └───────────┬───────────────────────────┘
             │ passes / blocked / annotated
             ▼
 ┌─────────────────────────┐
 │   Response to Customer    │
 └─────────────────────────┘
```

## 🔍 Explanation of Components

**Guardrail:** A named collection of controls that can be applied to one or many model deployments (and agents) in a Foundry project. A deployment has exactly one guardrail active at a time.

**Control:** The basic building block of a guardrail. Each control combines exactly one **risk** category, one or more **intervention points**, a **severity threshold**, and a **response action**.

**Risk:** The category of harmful content a control watches for. This lab's scope covers the four core content risks — **Hate**, **Sexual**, **Self-harm**, and **Violence**.

**Intervention point:** Where in the request/response flow a control evaluates content. Model guardrails in this lab use **user input** (the prompt) and **output** (the model's response). Agent guardrails additionally support **tool call** and **tool response** intervention points (Preview), covered only conceptually in this lab.

**Severity threshold:** The sensitivity level — **Low**, **Medium**, or **High** — at which a control triggers. A lower threshold is stricter and catches more content.

**Action:** What happens when a control triggers — **Annotate** (flag the content and return metadata, but let the response through) or **Annotate and block** (flag it and also prevent the response from reaching the caller).

**Microsoft.DefaultV2:** The built-in, non-editable guardrail automatically applied to every new model deployment in a Foundry project.

## 🚀 Getting Started with the lab

Welcome to your Microsoft Foundry Guardrails hands-on lab! We've prepared an environment for you to discover how Foundry's guardrails protect a model deployment from harmful content while keeping legitimate traffic flowing. Let's begin by making the most of this experience!

### Accessing Your Lab Environment

Once you're ready to dive in, your virtual machine and lab guide will be right at your fingertips within your web browser.

_[lab environment screenshot]_

### Lab Guide Zoom In/Zoom Out

To adjust the zoom level for the environment page, click the **A↕** icon located next to the timer in the lab environment.

_[zoom control screenshot]_

### Virtual Machine & Lab Guide

Your virtual machine is your workhorse throughout the lab. The lab guide is your roadmap to success.

### Exploring Your Lab Resources

To get a better understanding of your lab resources and credentials, navigate to the **Environment** tab.

_[environment tab screenshot]_

### Utilizing the Split Window Feature

For convenience, you can open the lab guide in a separate window by selecting the **Split Window** button from the top right corner.

_[split window screenshot]_

### Managing Your Virtual Machine

Feel free to **Start**, **Stop**, or **Restart** your virtual machine as needed from the **Resources** tab. Your experience is in your hands!

_[resources tab screenshot]_

### Let's Get Started with Azure Portal

On your virtual machine, click on the **Azure Portal** icon.

_[Azure Portal icon screenshot]_

You'll see the **Sign into Microsoft Azure** tab. Here, enter your credentials:

**Email/Username:** _[provided in your Environment tab]_

Next, provide your Temporary Access Pass:

**Temporary Access Pass:** _[provided in your Environment tab]_

If prompted to stay signed in, you can click **Yes**.

If a **Welcome to Microsoft Azure** pop-up window appears, simply click **Maybe later** to skip the tour.

### Signing In to Microsoft Foundry

In a new browser tab, go to [https://ai.azure.com](https://ai.azure.com) and sign in with the same lab credentials. Confirm you can see the pre-provisioned Foundry project for this lab before continuing to Module 0.

## 📞 Support Contact

The CloudLabs support team is available 24/7, 365 days a year, via email and live chat to ensure seamless assistance at any time. We offer dedicated support channels tailored specifically for both learners and instructors, ensuring that all your needs are promptly and efficiently addressed.

**Learner Support Contacts:**

- Email Support: cloudlabs-support@spektrasystems.com
- Live Chat Support: https://cloudlabs.ai/labs-support

Click **Next** from the bottom right corner to embark on your Lab journey!

Happy Learning!!!
