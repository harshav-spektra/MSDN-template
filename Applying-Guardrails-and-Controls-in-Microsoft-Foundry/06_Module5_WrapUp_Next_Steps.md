Module 5: Wrap-Up & Next Steps
Estimated Duration: 3 Minutes

## Scenario

Contoso's platform team has a working, tested guardrail and a clear troubleshooting process behind it. All that's left is to close out the lab environment responsibly and know where to go next once this design moves toward a real production rollout.

## Overview

In this final module, you will clean up the guardrail resources you created during the lab and review a short summary of everything you accomplished, along with links to further Microsoft reading on guardrails, intervention points, and content filtering.

## Objectives

- Task 1: Clean up resources
- Task 2: Review the lab summary and further reading

## Task 1: Clean up resources

In this task, you will remove the guardrail assignment and configuration you created for this lab.

1. Return to **Guardrails + controls** → **Guardrails**, and select `ContosoRetailGuardrail`.

1. Remove its assignment from your model deployment. Navigate to **Models + endpoints**, select your deployment, and confirm it now falls back to no custom guardrail assigned (or reassign Microsoft.DefaultV2, depending on your lab environment's cleanup convention).

1. Optionally, delete the custom guardrail itself if it will not be reused, to keep your project's guardrail list clean for future labs.

1. Confirm cleanup is complete:

   | Cleanup step | Confirmed? |
   |---|---|
   | Guardrail unassigned from deployment | |
   | Guardrail deleted (optional) | |

## Task 2: Review the lab summary and further reading

In this task, you will review what you accomplished across all six modules and where to continue learning.

1. Review the full arc of the lab:

   - **Module 0** — you learned the four core guardrail concepts (risk, intervention point, severity, action) and confirmed your environment prerequisites.
   - **Module 1** — you inspected the built-in Microsoft.DefaultV2 guardrail and confirmed it cannot be edited.
   - **Module 2** — you built `ContosoRetailGuardrail` from scratch, with four controls, tuned severity thresholds, both intervention points enabled, and the Annotate-and-block action, then applied it to your deployment.
   - **Module 3** — you proved the guardrail's behavior with real prompts: a benign baseline, triggered detections, a severity-level comparison, and a direct Annotate vs. Annotate-and-block comparison.
   - **Module 4** — you worked through Microsoft's troubleshooting checklist and tuning best practices, including the agent-override rule and the latency impact of guardrail processing.

1. For further reading, review the following official Microsoft Learn resources:

   - [Guardrails and controls overview in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/guardrails/guardrails-overview)
   - [How to configure guardrails and controls in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/guardrails/how-to-create-guardrails)
   - [Harm categories and severity levels in Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/openai/concepts/content-filter-severity-levels)
   - [Role-based access control for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/concepts/rbac-foundry)

## Summary

In this lab, you explored how Microsoft Foundry guardrails protect a model deployment from harmful content. You inspected the built-in Microsoft.DefaultV2 guardrail, built a custom guardrail — `ContosoRetailGuardrail` — with controls for Hate, Sexual, Self-harm, and Violence risks, each configured with its own severity threshold and intervention points, and applied it to a model deployment. You validated that configuration with real test prompts in the chat playground, directly comparing the Annotate and Annotate-and-block actions and observing how severity thresholds change what gets flagged. Finally, you worked through Microsoft's troubleshooting checklist and best practices for tuning guardrails in production, and cleaned up your lab resources.

You have successfully finished the lab.
