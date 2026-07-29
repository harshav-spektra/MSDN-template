# Exercise 2: Agent Framework Integration

### Estimated Duration: 90 Minutes

## 📘 Scenario

In the previous exercise, you used the repository's direct memory flow to observe how conversation state, summaries, and recall behave with a local backend. Contoso Health Services now wants its AI agents to manage memory automatically as part of the agent lifecycle, rather than through manual calls.

In this exercise, you will act as an AI Engineer responsible for studying how **AgentMemory** integrates with the **Microsoft Agent Framework**, running the financial advisor scenario to verify cross-session recall, comparing framework-managed memory with an agent-driven retrieval pattern, and analyzing how repeated sessions are curated into durable long-term insights.

## 📖 Overview

In this exercise, you will review the Microsoft Agent Framework integration pattern used by the repository, run multiple notebooks from the preloaded project, and compare two different approaches to memory retrieval:

- Framework-managed context injection with `context_providers=[memory]`
- Agent-driven retrieval, where the agent explicitly calls memory tools when it decides a lookup is needed
- Insight curation that turns repeated sessions into durable, evolving profile knowledge

You will work entirely from the prepared lab VM and the repository that was staged during deployment.

## 🎯 Objectives

In this exercise, you will perform:

- Task 1: Study the Integration Pattern
- Task 2: Run the Financial Advisor Demo
- Task 3: Compare Agent-Driven Memory Retrieval
- Task 4: Long-Term Insight Extraction

## Task 1: Study the Integration Pattern

In this task, you will open the Agent Framework notebook and inspect how `AgentMemory` is registered as a context provider inside the Agent Framework, identifying the lifecycle hooks that make memory automatic.

1. In the Explorer pane, navigate to the  **notebooks (1)** folder and open the **02_agent_framework.ipynb (2)** notebook.

   ![](./Images/ETS211.png)

1. Take a moment to read the first markdown cell, **"Agent Framework + AgentMemory Integration"**. It introduces the three key concepts you will observe in this exercise:

   ![](./Images/ETS244.png)

   - **ContextProvider pattern** — memory is passed as `context_providers=[memory]` to the Agent, so no manual `add_turn()` or `store_response()` calls are needed.
   - **Automatic context injection** — `before_run()` is called automatically when the agent processes a query, loading previous conversation context and the long-term profile.
   - **Automatic turn capture** — `after_run()` is called automatically after the agent responds, storing the new turn back into memory.

1. Scroll to the first code cell (**Step 1–6: Setup, Configuration & Agent Initialization**) and read it without running it yet. Locate the following integration points:

   - The **environment validation block**, which checks `AZURE_OPENAI_ENDPOINT`, `AZURE_OPENAI_API_KEY`, `AZURE_OPENAI_REASONING_MODEL`, and `AZURE_OPENAI_EMB_DEPLOYMENT`.

      ![](./Images/ETS214.png)

   - The **AgentMemoryConfig** block — note `auto_enrich_context=True` (automatic context injection is ON) and the `enrichment_trigger_keywords` list (words like "remember", "previous", "last time" that signal the user is referencing the past).

      ![](./Images/ETS215.png)
      
   - The **agent construction** at the bottom of the cell — find the key line:

     ```
     agent = Agent(
         client=chat_client,
         instructions="...",
         tools=[get_401k_limit, get_roth_ira_limit],
         context_providers=[memory],
     )
     ```

1. Verify the three integration points directly in the code:

   - **Which object supplies prior context to the agent:** it is the `memory` object (`AgentMemory`) — confirm it is the only item in the `context_providers=[memory]` list of the `Agent(...)` constructor.
   - **When context is loaded:** scroll to the docstring of the `run_session` helper in the next code cell — it states that `agent.run()` calls `memory.before_run()` internally, so context is injected **before** the model generates each response.
   - **When new turns are written back:** the same docstring shows `agent.run()` calls `memory.after_run()` internally after the response, so every turn is stored **automatically after** each reply — with no `add_turn()` call anywhere in the notebook. Press **CTRL + F** and search the notebook for `add_turn` to confirm there are zero matches in the conversation flow.

1. Compare this structure with what you saw in Exercise 1. Notice that the application code is no longer manually orchestrating every retrieval step; instead, memory participates as a context provider around the agent's run lifecycle.

## Task 2: Run the Financial Advisor Demo

In this task, you will execute the Agent Framework notebook and observe how memory from one session automatically influences later sessions, with no manual memory calls anywhere in the conversation code.

1. In the **02_agent_framework.ipynb** notebook, click **Select Kernel (1)** in the top-right corner and choose **agent-memory(3.12.X)(Python 3.12.X) (2)** if prompted.

   ![](./Images/ETS245.png)

1. Run the first code cell (**Step 1–6: Setup, Configuration & Agent Initialization**). This cell performs the complete initialization:

   ![](./Images/ETS241.png)

   - **Finds the project root** and loads your `.env` file.
   - **Validates the four required environment variables** and prints a ✅/❌ status for each.
   - **Defines the demo identifiers**: `USER_ID = "sarah_demo"` and the SQLite database `demo_financial_advisor.db`, deleting any previous copy for a clean run.
   - **Defines two lightweight financial tools** the agent can call: `get_401k_limit(year)` and `get_roth_ira_limit(year)`.
   - **Creates the Azure OpenAI client**, the **AgentMemoryConfig** (with `auto_enrich_context=True` and `longterm_synthesis_frequency=1` so the profile updates after every session), and initializes **AgentMemory**.
   - **Creates the Agent** with `context_providers=[memory]` — the single line that makes all memory management automatic.

   You should see the output ending with: `✅ INITIALIZATION COMPLETE - Agent ready for conversations!`

      ![](./Images/ETS222.png)

1. Read the next markdown cell, **"Step 7–8: Run Three-Session Demo"** — it previews what each session will demonstrate: Session 1 builds Sarah's profile, Session 2 recalls it automatically, and Session 3 uses the accumulated knowledge.

1. Run the next code cell (**Step 7–8: Run Three-Session Demo**). This cell runs the full multi-session scenario:

      ![](./Images/ETS242.png)

   - **Session 1 (Initial Consultation):** Sarah introduces herself — 35 years old, software engineer, $150,000/year, moderate-to-high risk tolerance, 30 years to retirement, employer 401k with 4% match. Watch the memory context line print `No previous memory - First session!`
   - **Session 2 (Investment Strategy):** the user asks *"Based on what we discussed before, what asset allocation do you recommend?"* — watch the `📚 Memory context loaded` line at session start: the agent receives Sarah's profile automatically before answering.
   - **Session 3 (Tax Planning):** the user asks about tax optimization *"given my income and the retirement accounts we discussed"* — the agent uses knowledge accumulated across both earlier sessions.
   - After each session ends, note the `💡 Insights extracted` count — ending a session triggers reflection and profile updates automatically.

   ![](./Images/ETS224.png)

1. Verify that Session 2 and Session 3 reference information established earlier (age, income, risk tolerance, time horizon) rather than behaving like a stateless first-time conversation.

1. Locate at least two concrete examples of recalled information in the output:

   - In the **Session 2** output, find the agent referencing Sarah's **risk tolerance** or **30-year time horizon** (stated only in Session 1) when recommending an asset allocation.

   ![](./Images/ETS225.png)

   - In the **Session 3** output, find the agent referencing Sarah's **$150,000 income** or the **retirement accounts discussed earlier** when giving tax optimization advice.

   ![](./Images/ETS226.png)

   >**Note**: To verify the complete output block, scroll down to the end of the output and click on **scrollable element**.

1. Run the final code cell (**Step 9–10: Inspect Memory & Cleanup**). This cell verifies what was stored:

   ![](./Images/ETS243.png)   

   - **Memory search test** — runs `memory.search("What is Sarah's risk tolerance?")` and prints the semantically retrieved answer.
   - **Sessions list** — `memory.get_sessions()` should show all three sessions with their generated summaries.
   - **Extracted insights** — `memory.get_insights()` prints what the system learned about Sarah, each with a category and confidence score.
   - **Cleanup** — closes the memory connection and deletes the demo database.

   ![](./Images/ETS228.png)    

1. Confirm in the final output that the pattern held end to end: three sessions recorded, insights extracted for Sarah's demographics, risk tolerance, and goals — all without a single manual `add_turn()`, `store_response()`, or `get_context()` call in the conversation code. This is why the pattern suits scenarios like a financial advisor, where preferences, goals, and risk posture must persist across many interactions automatically.

## Task 3: Compare Agent-Driven Memory Retrieval

In this task, you will run the agent-driven notebook, where automatic context injection is disabled and the agent must explicitly decide when to search memory — and observe a safety-critical scenario that tests whether it does.

1. In the Explorer pane, navigate to the  **notebooks (1)** folder and open the **03_agent_driven.ipynb (2)** notebook 

   ![](./Images/ETS231.png)

1. Read the first markdown cell, **"Agent-Driven Memory Demo"**. It contrasts the two approaches directly:

   - **Managed context (previous notebook):** the system automatically decides when to search; the agent passively receives pre-enriched context.
   - **Agent-driven (this notebook):** the agent has explicit memory tools and decides for itself when to call them — making memory access transparent, auditable, and reasoned.

   ![](./Images/ETS232.png)

1. In the **03_agent_driven.ipynb** notebook, click **Select Kernel (1)** in the top-right corner and choose **agent-memory(3.12.X)(Python 3.12.X) (2)** if prompted.

   ![](./Images/ETS233.png)

1. Run the first code cell (**Step 1: Setup, Imports & Configuration**).

   ![](./Images/ETS246.png)

1. Note the one critical difference from the previous notebook:

   ```
   config = AgentMemoryConfig(
       auto_enrich_context=False,
       auto_manage_sessions=False,
       longterm_synthesis_frequency=1,
   )
   ```

      ![](./Images/ETS236.png)

   **`auto_enrich_context=False`** — automatic injection is disabled. The agent will only see past information if it explicitly searches for it. This cell also sets `USER_ID = "patient_demo"` and creates the `demo_agent_driven_memory.db` database.

   You should see the output ending with: `✅ Step 1 Complete: Environment configured`

   ![](./Images/ETS235.png)   

1. Run the next code cell (**Step 2: Create Memory Tools & Agent With Explicit Memory Control**). This cell gives the agent its explicit memory tools:

   ![](./Images/ETS247.png)

   - **`search_memory(query)`** — searches the patient's history across interactions, insights, and summaries. Its tool description instructs the agent: *"CRITICAL: Always search before prescribing medications or making recommendations!"*
   - **`get_patient_profile()`** — retrieves the synthesized patient profile built from all past sessions.
   - The agent is then created with `tools=[search_memory, get_patient_profile]` — and **no** `context_providers`.

   You should see the output ending with: `✅ Step 2 Complete: Agent ready with memory control`

   ![](./Images/ETS239.png)

1. Run the next code cell (**Step 3: Run Three-Session Medical Demo**). Watch each session carefully:

   ![](./Images/ETS248.png)

   - **Session 1 (Initial Consultation):** the patient discloses a **severe penicillin allergy with anaphylaxis history**. The system stores this.
   - **Session 2 (Routine Follow-up):** a simple blood pressure check — the allergy is not mentioned, and a memory search is optional here.
   - **Session 3 (THE CRITICAL TEST):** the patient says *"I have a really bad sinus infection. I think I need antibiotics."* — **without mentioning the allergy**. Watch the output for a `🔍 [Agent Tool] search_memory(...)` line: the agent must proactively decide to search memory for allergies before recommending any antibiotic.

   ![](./Images/ETS2310.png)   

1. Verify in the Session 3 output that the agent invoked `search_memory` and that its response accounts for the penicillin allergy from Session 1.

   ![](./Images/ETS2312.png)   

1. Run the final code cell (**Step 4: Inspect Final Memory State & Key Learnings**). 

   ![](./Images/ETS249.png) 

1. This cell prints the extracted insights (the allergy should appear with its category and confidence), the three recorded sessions with summaries, a semantic search test for `"patient allergies medications"`, and then cleans up the database.

   ![](./Images/ETS2314.png) 

1. Compare the two notebooks side by side by locating the concrete evidence of each pattern:

   - Open both notebooks in split view (right-click the **03_agent_driven.ipynb** tab and select **Split Right**).
   - In **02_agent_framework_condensed.ipynb**, observe that memory access is **invisible** in the session output — context simply appears in the `📚 Memory context loaded` line, with no tool calls shown. This is what "automatic" looks like: convenient, but you cannot see when or why memory was consulted.
   - In **03_agent_driven.ipynb**, observe the explicit `🔍 [Agent Tool] search_memory('...')` lines in the Session 3 output — every memory access is visible, logged, and attributable to an agent decision. This is what makes the agent-driven pattern easier to debug: if context was not recalled, the missing tool call shows you exactly where the failure happened.

1. Review the following comparison of the two patterns, and verify each row against what you observed in the outputs:

   | Pattern | Strength | Trade-off | Best-fit scenario |
   |---|---|---|---|
   | Framework-managed (`context_providers=[memory]`) | Seamless — zero memory code in the conversation flow; context always present | Opaque — cannot see when/why memory was used; may inject irrelevant context | Consumer assistants, advisors, and multi-turn experiences where continuity should feel natural |
   | Agent-driven (explicit `search_memory` tools) | Transparent and auditable — every access is a visible, logged tool call the agent must justify | Relies on the agent deciding to search; a missed search means missed context | Safety-critical domains (medical, legal, financial compliance) where memory access must be verifiable |

   > **Note:** The goal of this task is not to declare one pattern universally better. Instead, you are identifying when framework-managed context injection is helpful and when explicit retrieval offers better observability, safety, or control.

## Task 4: Long-Term Insight Extraction

In this task, you will run the insight curation notebook and observe how repeated sessions evolve into durable user understanding — including how the system resolves outright contradictions between sessions instead of blindly accumulating them.

1. In the Explorer pane, navigate to the  **notebooks (1)** folder and open the **06_insight_curation.ipynb (2)** notebook

   ![](./Images/ETS411.png)

1. Read the first markdown cell, **"Insight Curation Demo: Contradiction Resolution & Profile Evolution"**.

   ![](./Images/ETS418.png)

 It frames the core problem this notebook solves:

   - Session 1 stores *"User avoids stocks completely due to 2008 trauma"*.
   - Session 2 stores *"User is now aggressive — 90% stocks"*.
   - A naive system keeps both contradictory insights forever; a curated system **resolves** them into an evolution narrative: *"User WAS conservative, is NOW aggressive."*

1. Run the first code cell (**Step 1: Environment Setup & Configuration**).

   ![](./Images/ETS413.png)

   Note the key configuration:

   ```
   config = AgentMemoryConfig(
       buffer_size=6,
       longterm_synthesis_frequency=1,
   )
   ```

   **`longterm_synthesis_frequency=1`** — the profile is synthesized after **every** session (rather than every few sessions), which is what enables contradiction detection between Session 1 and Session 2. This cell uses `USER_ID = "evolving_user_demo"` and the `demo_insight_curation.db` database.

   You should see the output ending with: `✅ Step 1 Complete: Environment configured`

      ![](./Images/ETS414.png)

1. Run the next code cell (**Step 2: Run Two Simulated Sessions - Demonstrating Profile Evolution**). 

      ![](./Images/ETS415.png)

   This cell replays two pre-scripted sessions for a user named Alex:

   - **Session 1 (Risk-Averse Beginner):** Alex is a new graduate making $55,000, traumatized by watching his family lose money in 2008 — *"No stocks ever. Just bonds and savings accounts for me."*
   - **Session 2 (Two Years Later — the CONTRADICTION):** Alex got promoted to $120,000, has a year of expenses saved, and now wants to be *"AGGRESSIVE — 90% stocks"*, seeing market drops as *buying opportunities*.
   - Watch the output banner between the sessions explicitly warning: *"Contradiction coming in next session... System must resolve this contradiction!"* — and the Profile Evolution Summary at the end: `WAS conservative → NOW aggressive, Status: Contradiction RESOLVED by system`.

   You should see the output ending with: `✅ Step 2 Complete: Profile evolution demonstrated`.

      ![](./Images/ETS416.png)

1. Read the next markdown cell, **"Step 3: Run Verification Session with Real LLM"** and run the code cell.

      ![](./Images/ETS419.png)

   This cell runs a genuine LLM call:
   - **The scenario:** Alex received a $10,000 bonus, and his dad is advising him to *"put it all in a savings account because the market has been volatile."*
   - **The test:** the notebook retrieves the evolved profile via `get_context()`, injects it into the system prompt, and asks the real model for advice.
   - **Success looks like:** the response references Alex's current aggressive 90%-stock stance and treats volatility as opportunity. **Failure looks like:** the response sides with the dad's conservative advice — meaning the old Session 1 profile leaked through.

1. Verify in the output which profile the model used, and note the success/failure indicators the cell prints.

      ![](./Images/ETS4111.png)

1. Run the final code cell (**Step 4: Final Analysis & Key Learnings**).

      ![](./Images/ETS4110.png)


   This cell categorizes the stored insights into **conservative**, **aggressive**, and **evolution/change** buckets, prints an explicit contradiction-resolution analysis, and cleans up the memory connection and database.

      ![](./Images/ETS4112.png)

1. Verify the curation behavior directly in the final analysis output:

   - **What survives beyond a single session:** in the `💡 Insights Extracted` list, confirm that durable facts about Alex (income level, risk stance, investment goals) are present — while conversational filler from the sessions is not.
   - **Why repeated background questions are avoided:** in the Step 3 verification output, confirm the `📚 PROFILE CONTEXT PROVIDED TO LLM` block already contained Alex's situation — the model never had to ask his age, income, or risk tolerance again.
   - **The risk of stale insights:** in the `🔍 PROFILE CONTRADICTION ANALYSIS`, confirm the system reports both conservative and aggressive insights but merged them into an evolution narrative — if the outdated Session 1 insight had been retained as-is, the verification session would have produced the conservative (wrong) advice.

1. Review the full progression you have now demonstrated across both exercises, verifying you can point to where each pattern appeared:

   - **Direct memory usage** (Exercise 1) — manual `add_turn()` and `get_context()` calls in `01_basic_memory.ipynb`.
   - **Framework-integrated memory** (Task 2.2) — `context_providers=[memory]` with automatic `before_run()`/`after_run()` hooks.
   - **Agent-driven retrieval** (Task 2.3) — explicit `search_memory` tool calls visible in the output.
   - **Long-term insight curation** (this task) — contradiction resolution and profile evolution with `longterm_synthesis_frequency=1`.

   You will use the same mental model again when you move into cloud-backed persistence and bounded long-term memory in later exercises.

## 🧾 Summary

In this exercise, you accomplished the following:

- Opened the `02_agent_framework.ipynb` notebook and inspected the Agent Framework integration, identifying `context_providers=[memory]` and the `before_run()`/`after_run()` lifecycle hooks
- Ran the three-session financial advisor demo and verified automatic cross-session recall of Sarah's profile (age, income, risk tolerance, time horizon) with zero manual memory calls
- Ran the agent-driven notebook with `auto_enrich_context=False`, observed the agent explicitly invoking the `search_memory` tool, and validated the safety-critical scenario where the agent recalled a penicillin allergy before an antibiotic recommendation
- Compared the framework-managed and agent-driven patterns across convenience, transparency, debuggability, and best-fit scenarios
- Ran the insight curation notebook and observed contradiction resolution and profile evolution (conservative → aggressive), verified with a real LLM call that the evolved profile drives personalized responses

You have successfully completed this exercise. Click **Next >>** to continue to the next exercise.
