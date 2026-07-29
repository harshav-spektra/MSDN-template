# Exercise 4: Bounded Long-Term Memory & Insight Curation

### Estimated Duration: 60 Minutes

## 📘 Scenario

In the previous exercises, you stored memory in SQLite (locally) and Cosmos DB (cloud). In both cases, every insight extracted from every session accumulated without limit. For a short demo that works fine — but imagine an agent that has been talking to the same user for a year. If it keeps every insight forever, its memory grows without bound: it gets slow, expensive, and starts injecting irrelevant or even *contradictory* facts into every conversation.

This exercise shows two approaches to solving that problem. In **Task 2** you will run a notebook that applies a **hard cap** — the agent is only ever allowed to hold 5 insights at a time, and lower-scoring ones are automatically deleted. In **Task 3** you will compare that with the **insight curation** notebook from Exercise 2, which instead focuses on *resolving contradictions* — detecting when a newer session directly contradicts an older one and merging them into a coherent evolution narrative.

By the end of this exercise you will be able to clearly explain when to use each strategy and why.

## 📖 Overview

In this exercise, you will:

- Understand how the itemized insights pattern bounds memory capacity using four scoring rules (recency, frequency, forgetting, and a hard cap)
- Run `08_itemized_insights.ipynb` — six simulated monthly sessions for a financial advisor client, with a `MAX_INSIGHTS = 5` cap enforced after every session
- Compare the bounded itemized approach with the contradiction-resolving insight curation approach from `06_insight_curation.ipynb`
- Verify the difference by reading both outputs side by side and confirming which pattern fits which real-world scenario

## 🎯 Objectives

In this exercise, you will perform:

- Task 1: Understand the Itemized Insights Pattern
- Task 2: Run Itemized Insights Demo (SQLite)
- Task 3: Compare Synthesis Strategies

## Task 1: Understand the Itemized Insights Pattern

In this task, you will learn what bounded memory means, understand the four scoring rules the notebook uses, and open the notebook to inspect its configuration before running any cells.

### What does "bounded" mean?

**Unbounded memory** — every insight the agent extracts is stored forever. After 100 sessions, the agent has hundreds of insights. Many of them are stale, redundant, or no longer accurate. The agent injects all of them into every prompt, which wastes tokens and degrades response quality.

**Bounded memory** — you set a hard ceiling, for example `MAX_INSIGHTS = 5`. The agent can never hold more than 5 insights at any time. When a new insight arrives and the count would exceed 5, the *least valuable* existing insight is permanently deleted to make room. This forces the memory to stay compact and relevant.

### How does it decide which insights to delete?

The notebook scores every insight using four rules, then deletes the lowest-scoring one:

| Rule | What it means | Effect |
|---|---|---|
| **Recency** | A brand-new insight gets a temporary boost | Protects new information from being immediately discarded |
| **Frequency** | Every time an insight is *cited* in a later session, its `access_count` increases | Insights that keep proving useful become stronger over time |
| **Forgetting** | An insight that is never cited again slowly decays | Old, never-referenced insights gradually weaken |
| **Bounded Capacity** | If total insights exceed `MAX_INSIGHTS`, delete the weakest | Enforces the hard cap |

The result is a memory system that behaves like human long-term memory: frequently-used facts stay sharp, and old unused details fade away.

1. In the Explorer pane, navigate to the  **notebooks (1)** folder and open the **08_itemized_insights.ipynb (2)** notebook.

   ![](./Images/ETS411.png)

1. Read the first markdown cell, **"Long-Term Memory Prioritization Demo (SQLite)"**. Confirm it lists the same four concepts described above: **Recency**, **Frequency**, **Forgetting**, and **Bounded Capacity**.

   ![](./Images/ETS421.png)

1. Click **Select Kernel (1)** in the top-right corner and select the project's virtual environment, for example **.venv (Python 3.12.x) (2)**.

   ![](./Images/ETS422.png)

1. Without running any cells yet, scroll to the first code cell (**Cell 1**) and locate the following two lines near the top of the configuration block:

   ```python
   USER_ID = 'memory_priority_demo'
   MAX_INSIGHTS = 5
   ```

   - **`USER_ID`** — the unique identifier for the fictional user whose memory this demo manages.
   - **`MAX_INSIGHTS = 5`** — the hard cap. This single number is what makes memory bounded. The notebook will never allow more than 5 insights to exist at once for this user.

1. Also scroll through the `TIMELINE` list defined in Cell 1. You will see six entries — one per simulated month. Each entry has:

   - A `simulated_date` (January through June 2025)
   - A `title` (e.g., *"Month 1: Initial Consultation"*)
   - A `summary` describing what the user said that month
   - A `turns` list of the actual user/assistant conversation

      ![](./Images/ETS428.png)

   > **Note:** The sessions are pre-scripted so the demo runs without user input and completes in under two minutes. You are observing what the system *does* with those conversations, not having a live chat.

1. Read the markdown cell **"Cell 4: Clear Execution Walkthrough"** to preview what will happen when you run the main cell. It outlines five steps: reset state → initialize storage → simulate six sessions → extract and reinforce memory → apply pruning.

## Task 2: Run Itemized Insights Demo (SQLite)

In this task, you will execute the three code cells in `08_itemized_insights.ipynb` one by one and observe how the insight table evolves — with entries being added, strengthened, and pruned — across six simulated sessions.

1. Run the first code cell (**Cell 1 :  Setup, Import & Configuration**). 

   ![](./Images/ETS423.png)

   This cell:
   - **Loads your `.env` file** from the project root so the notebook can authenticate to Azure OpenAI.
   - **Imports the low-level classes** directly: `SQLiteDatabase` (for local file storage), `OpenAIEmbeddingProvider` (for embedding-based insight extraction), `Reflection` (the component that analyses sessions and extracts insights), and the insight scoring utilities: `LongTermInsightItem`, `rank_insights`, `calculate_retention_score`.

     > **Note:** Unlike previous notebooks that used the high-level `AgentMemory` wrapper, this notebook works at a lower level — it talks directly to the database and the reflection engine. This gives you full visibility into the scoring and pruning logic that `AgentMemory` normally handles automatically.

   - **Creates the Azure OpenAI client** using your endpoint and API key.
   - **Sets `DB_PATH`** to `demo_memory_priority.db` in the project root — a local SQLite file. This file is deleted and recreated at the start of every run so results are clean and reproducible.
   - **Builds the `TIMELINE`** — Alex's six-month story, progressing from a risk-averse beginner (Month 1) to someone who opens a Roth IRA (Month 2), asks tax questions (Month 3), and whose profile continues to evolve through June.

      You should see: `[Setup complete]` or equivalent output.

     ![](./Images/ETS424.png)

1. Run the second code cell (**Cell 2 — Helper Functions**). 

   ![](./Images/ETS425.png)

   This cell defines the four functions the main demo uses:

   - **`print_insight_table(items, now, title)`** — prints the formatted insight table you will see throughout the run. The columns are:
     - `ID` — a short unique identifier for each insight.
     - `Score` — the calculated retention score (higher = safer from pruning).
     - `Access` — how many times this insight has been cited in later sessions (this is the frequency score — it goes up each time the reflection engine references this insight ID in a new session).
     - `Age` — how old this insight is relative to the simulated date.
     - `Importance` — the importance rating assigned when the insight was first extracted.
     - `Text` — the first 38 characters of the insight text.

   - **`get_insight_items(db, user_id)`** — reads all current insights from the SQLite database.
   - **`prune_insights(db, user_id, items, max_items, now)`** — the core pruning function: ranks all insights by score, keeps the top `max_items`, and **permanently deletes** the rest from the database.
   - **`run_session_with_simulated_time(...)`** — processes one session: injects existing insights as context, calls the reflection engine to extract new insights, increments `access_count` on any cited existing insights, and saves new insights to the database.

      You should see output as: `Helper functions are ready`

      ![](./Images/ETS426.png)

1. Run the main code cell (**Cell 3: Run Full Simulation with 6 Monthly Sessions**). 

      ![](./Images/ETS4277.png)

   This is the cell that runs all six sessions and applies the pruning logic after each one. The output is long — read it section by section:

   **Startup banner:**
   ```
   LONG-TERM MEMORY PRIORITIZATION DEMO
   Key concepts demonstrated:
   - RECENCY: New insights start with a grace-period boost
   - FREQUENCY: Cited insights gain strength (access_count increases)
   - FORGETTING: Old, uncited insights decay over time
   - BOUNDED MEMORY: Only 5 insights retained
   ```

   **For each of the six sessions, watch for this repeating pattern:**

   *Header line:*
   ```
   SESSION 1: Month 1: Initial Consultation
   Simulated Date: January 15, 2025
   ```

   *Before the session — Memory State BEFORE Session:*
   - In Session 1 you will see: `[No existing insights - this is the first session]`
   - In Sessions 2–6 you will see the full insight table showing which insights existed before this session processed.

   *During the session:*
   ```
   [Processing session...]
   Summary: Alex is 28, software engineer earning $120k...
   New insights: 3
     - [abc12] Alex is 28 years old, works as a software...
     - [def34] Alex prefers conservative investments due...
     - [ghi56] Alex has $10,000 emergency fund saved...
   ```

   *Cited existing insights (Sessions 2 onwards):*
   ```
   Cited existing: ['abc12', 'def34']
   ```
   When you see this, it means the reflection engine recognized that these two earlier insights were still relevant to this session. Their `access_count` will have increased by 1 — making them harder to prune.

   *After the session — when the cap is exceeded:*
   Once total insights exceed `MAX_INSIGHTS = 5`, you will see the pruning decision:
   ```
   Capacity exceeded (6 > 5). Pruning...
   Forgotten:
     - [xyz99] score=0.31 age=45d access=0: Alex mentioned saving for sister's...
   Retained:
     - [abc12] score=1.87 age=60d access=2: Alex is 28 years old, works as a so...
     - [def34] score=1.52 age=60d access=1: Alex prefers conservative investmen...
     ...
   ```
   The pruned item has `access=0` — it was never cited again after it was created, so its score decayed. The retained items all have higher scores, typically because they were cited in at least one later session.

   *After the session — Memory State AFTER Session (Top 5):*
   The insight table now shows the state of memory after pruning. **The total row count should never exceed 5.**

      ![](./Images/ETS429.png)

1. After all six sessions complete, scroll back through the output and verify the following:

   - In **Session 1** the insight table was empty before and had 3–4 entries after.
   - By **Session 4 or 5** the total count first exceeded 5 — look for the `Capacity exceeded` line and verify that exactly one insight was pruned.
   - The pruned insight in each case had `access=0` — it was never referenced again, so its score decayed below the retained items.
   - In the **final session's AFTER table**, the total row count is exactly 5 (or fewer if fewer than 5 unique insights were ever extracted).

      ![](./Images/ETS429.png)

## Task 4.3: Compare Synthesis Strategies

In this task, you will open the `06_insight_curation.ipynb` notebook (which you ran in Exercise 2), re-run it to refresh its output, and then place both notebooks side by side to compare the two strategies across four dimensions. No new concepts are introduced — the goal is to lock in a clear mental model you can use when designing real agent memory systems.

### What is the difference between the two strategies?

Before you run anything, read this summary so you know what to look for in the output:

| | `08_itemized_insights.ipynb` (this exercise) | `06_insight_curation.ipynb` (Exercise 2) |
|---|---|---|
| **What it does** | Holds a hard cap of 5 insights. When the cap is hit, the weakest insight is deleted | Synthesizes a free-form narrative profile after every session. No cap on size |
| **How contradictions are handled** | Older contradicted insights are likely to decay (low access count) and eventually get pruned | Contradictions are explicitly detected and resolved into an evolution narrative (*"User WAS conservative, NOW aggressive"*) |
| **Output style** | A scored, tabular list of short insight strings | A narrative profile that evolves and is actively rewritten |
| **Best fit** | Long-running agents where memory size must stay predictable | Agents where understanding *how* a user's situation changed over time is important |

1. In the Explorer pane, open the **06_insight_curation.ipynb** notebook   - Right-click the **06_insight_curation.ipynb (1)** tab at the top and select **Split Right (2)** along with `08_itemized_insights.ipynb`:

      ![](./Images/ETS431.png)

1. This places both notebooks side by side so you can compare their output directly.

      ![](./Images/ETS432.png).

1. Now compare the two notebooks side by side. Verify each row of the following table against the output you see in both panes:

   | Dimension | `08_itemized_insights.ipynb` | `06_insight_curation.ipynb` |
   |---|---|---|
   | **Scale** | Insight count stays at exactly 5 regardless of how many sessions run | Insights accumulate freely — count grows with every session |
   | **Contradiction handling** | Contradicted insights decay naturally if they stop being cited — they are not explicitly detected, just gradually pruned | Contradictions are explicitly detected and resolved into a single evolution narrative: *"WAS conservative → NOW aggressive"* |
   | **Human readability** | A clean, scored table of short facts — easy for a developer or operator to review at a glance | A narrative profile — richer context but harder to audit at scale |
   | **Production fit** | Best for long-running agents where memory size, cost, and latency must stay predictable | Best for agents where understanding *how* a user's situation changed matters (e.g., financial advisor, career coach) |

1. Confirm you can explain the difference between the two strategies in one sentence each:

   - **`08_itemized_insights`:** find the final session's `Memory State AFTER Session (Top 5)` table in the left pane — this is a bounded, scored list of the 5 most valuable facts the agent knows about Alex.
   - **`06_insight_curation`:** find the `evolution_insights` section in Cell 7's output in the right pane — this is a narrative that explicitly describes *how* Alex's profile changed over time, not just what it is now.

      ![](./Images/ETS433.png).

## 🧾 Summary

In this exercise, you accomplished the following:

- Understood the four scoring rules behind bounded itemized memory — **recency** (new insight grace period), **frequency** (`access_count` rises when cited), **forgetting** (uncited insights decay), and **bounded capacity** (`MAX_INSIGHTS = 5`) — and confirmed `MAX_INSIGHTS = 5` and `USER_ID = 'memory_priority_demo'` in Cell 1 of `08_itemized_insights.ipynb`
- Ran `08_itemized_insights.ipynb`'s three cells and observed the full six-session simulation: each session's **BEFORE** and **AFTER** insight table, the `Cited existing` line showing frequency reinforcement, and the `Capacity exceeded → Pruning` decision deleting the lowest-scoring (always `access=0`) insight to keep the total at 5
- Opened `06_insight_curation.ipynb` in split view, re-ran its four cells, and observed the two contradicting sessions (conservative Session 1 vs. aggressive Session 2), the `Contradiction RESOLVED` banner, the real-LLM verification confirming the evolved profile was used (not the old conservative one), and the final categorization of insights into conservative, aggressive, and evolution buckets
- Compared both strategies across scale, contradiction handling, human readability, and production fit — confirming that bounded itemized memory suits long-running agents where size must stay predictable, while synthesis-based curation suits agents where understanding *how* a user evolved over time is the priority

You have successfully completed this exercise. Click **Next >>** to continue to the next exercise.
