# Exercise 5: Live Server Mode & Streamlit UI

### Estimated Duration: 90 Minutes

## 📘 Scenario

In every previous exercise, memory logic ran **inside the same Python process** as the notebook. The notebook imported `AgentMemory`, held the database connection, and managed sessions — all in one place. That worked for learning the concepts, but it is not how real applications are built.

In production, you typically have:

- **One memory service** — a long-running HTTP server that owns the database connection, manages sessions, and extracts insights. It runs independently of any client.
- **Many clients** — a browser UI, a terminal chat tool, a mobile app, or another microservice. Each client makes HTTP requests to the memory service and never touches the database directly.

This is exactly what you will build and explore in this exercise.

You will start the **FastAPI memory server**, confirm it is healthy, then connect **two different clients** to it: the **scripted terminal demo** and the **Streamlit browser UI**. You will watch memory build turn by turn, see insights extracted at session end, and — in the final task — type your **own prompts** into the terminal client and then switch to the browser to see those exact messages stored and reflected. That loop — type in terminal, verify in browser — is the architecture made tangible.


## 📖 Overview

```
┌─────────────────────────────────────────────────────┐
│               Your Lab VM                           │
│  ┌──────────────────────────────────────────────┐   │
│  │    FastAPI Memory Server  (port 8000)        │   │
│  │    server/main.py                            │   │
│  │    AgentMemory + Database + Reflection       │   │
│  └──────────┬─────────────────┬─────────────────┘   │
│             │ HTTP            │ HTTP                │
│  ┌──────────▼──────┐  ┌───────▼──────────────────┐  │
│  │ Terminal client │  │ Streamlit UI (port 8501) │  │
│  │ 05_server_      │  │ 07_interactive_ui.py     │  │
│  │ mode.py         │  │ Browser: localhost:8501  │  │
│  └─────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

> **Key point:** Neither the terminal client nor the Streamlit UI imports `AgentMemory`. Neither holds a database connection. They are just HTTP clients. All memory logic lives exclusively in the server.


## 🎯 Objectives

- Task 1: Start and validate the FastAPI memory server
- Task 2: Run the scripted terminal demo and observe what the server records
- Task 3: Launch the Streamlit UI and watch memory build turn by turn
- Task 4: Verify cross-session recall — Session 2 loading Session 1's memory
- Task 5: Interactive — Type your own prompts and verify them in the browser

## Task 1: Start and Validate the FastAPI Memory Server

In this task, you will start the server in its own terminal and verify it is healthy before connecting any clients.

### What is the FastAPI memory server?

In earlier exercises, every notebook contained:

```python
memory = AgentMemory(user_id=USER_ID, openai_client=client, ...)
await memory.start_session()
await memory.add_turn(user_msg, agent_msg)
await memory.end_session()
```

The server wraps these same operations behind **HTTP endpoints**. Instead of a Python function call, a client sends:

```
POST http://127.0.0.1:8000/sessions/start
POST http://127.0.0.1:8000/turns/store
GET  http://127.0.0.1:8000/memory/context
POST http://127.0.0.1:8000/sessions/end
```

The client never needs to know how memory works — it only needs the server URL.

1. Click on the **ellipsis (...) (1)** in the top menu, then select **Terminal (2)** and click **New Terminal (3)**.

   ![](./Images/ETS117.png)

1. Start the FastAPI memory server:

   ```
   uv run uvicorn server.main:app --host 127.0.0.1 --port 8000
   ```

   > **What this means:** `server.main:app` tells Uvicorn to open `server/main.py` and find the `app` variable — the FastAPI application object. `--host 127.0.0.1` restricts it to your local machine. `--port 8000` is the port both clients will use.

1. Watch for the startup confirmation:

   ```
   INFO:     Application startup complete.
   INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
   ```

   > **Do NOT close Terminal 1 or press Ctrl+C during this exercise.** Both clients fail immediately if the server stops.

1. Open a **second terminal** (click the **+** icon). This is **Terminal 2 — your client terminal**.

1. Verify the server health. On the Windows lab VM (PowerShell):

   ```
   Invoke-RestMethod http://127.0.0.1:8000/health
   ```

   > **Why `Invoke-RestMethod` and not `curl`?** On Windows, `curl` is aliased to `Invoke-WebRequest` and throws an Internet Explorer engine parsing error. `Invoke-RestMethod` returns JSON already parsed.

1. Confirm the response:

   ```
   status  active_sessions uptime_seconds
   ------  --------------- --------------
   healthy               0     4.892
   ```

   - **status: healthy** — server started successfully, connected to its database, ready to receive requests.
   - **active_sessions: 0** — no clients connected yet. This increments as clients start sessions.
   - **uptime_seconds** — how long the process has been alive.

## Task 2: Run the Scripted Terminal Demo and Observe What the Server Records

In this task, you will run the scripted demo — a fixed 5-turn automatic conversation — and observe the complete memory lifecycle: session start → turns stored → session end → insights extracted.

### What the scripted demo does

The script runs this conversation automatically:

| Turn | User says | Purpose |
|---|---|---|
| 1 | "Hi! I'm looking for advice on saving for retirement. I'm 35 years old." | Establishes age |
| 2 | "Yes, I have a 401k through my employer. They match up to 6%." | Establishes employer match |
| 3 | "I'm currently contributing 8%, so I'm getting the full match. Should I contribute more?" | Establishes contribution level |
| 4 | "What about a Roth IRA? Is that something I should consider at my age?" | Key question for insight extraction |
| 5 | "That makes sense. What's the contribution limit for a Roth IRA?" | Confirms topic interest |

### Steps

1. In Terminal 2, run:

   ```
   uv run python demo/05_server_mode.py --scripted
   ```

1. Watch the connection confirmation:

   ```
   ✓ Memory service: healthy
   ✓ Session started: a3f8b2c1...
   ```

   > The script called `POST http://localhost:8000/sessions/start`. Notice `05_server_mode.py` has no `AgentMemory(...)` constructor — only HTTP calls.

1. Watch each turn as it stores:

   ```
   [Turn 1]
   User: Hi! I'm looking for advice on saving for retirement. I'm 35 years old.
   Advisor: Great that you're thinking about retirement at 35! ...
     → Stored (turn 1)
   ```

   Each `→ Stored (turn N)` line means `POST http://localhost:8000/turns/store` was called and the server ran `AgentMemory.add_turn()` internally.

1. After all 5 turns, the script attempts a semantic search. You may see one of two outcomes:

   **Outcome A — Search succeeds:**
   ```
   Searching memory for 'Roth IRA'...
   Results: ...the Roth IRA contribution limit is $7,000...
   ```

   **Outcome B — ReadTimeout error (known issue):**
   ```
   Searching memory for 'Roth IRA'...
   httpx.ReadTimeout
   ```

   > **If you see Outcome B:** This is a known timeout issue. The semantic search generates an embedding via Azure OpenAI before searching, which can exceed the HTTP client's default timeout under lab conditions. **Your session data is completely intact** — all 5 turns were stored before this step ran. The search concept is demonstrated visually in Task 5.3 through the Key Insights panel. To retry with a longer timeout:
   > ```
   > $env:HTTPX_TIMEOUT=60; uv run python demo/05_server_mode.py --scripted
   > ```

   > **If the script crashed with a full traceback after the search step:** This happened because the ReadTimeout was not caught and exited the process. Your 5 turns are still stored correctly. Continue to Task 5.3.

1. Whether the search succeeded or timed out, look for the session end summary:

   ```
   ======================================================================
   ✅ Demo Complete!
   ======================================================================
   Turns: 5
   Insights extracted: 3
   Long-term synthesis: Yes
   Summary: User is a 35-year-old beginning retirement planning. Has a
   401k with 4% employer match, contributing 8%. Interested in Roth IRA...
   ```

   > **What happened at session end:** The server ran the reflection engine across all 5 turns, extracted 3 durable insights, and wrote them to the database. These will be loaded automatically into any future session for the same `user_id`.

1. Switch to **Terminal 1** (the server terminal) and scroll the log. Confirm:

   ```
   INFO: POST /sessions/start - 200
   INFO: POST /turns/store - 200   (× 5)
   INFO: GET  /memory/context - 200
   INFO: POST /sessions/end - 200
   ```

   > Every operation was an HTTP request. `05_server_mode.py` is just an HTTP client. All memory logic ran inside `server/main.py`.

## Task 3: Launch the Streamlit UI and Watch Memory Build Turn by Turn

In this task, you will open the Streamlit browser UI and use its playback controls to replay a scripted scenario while watching the Memory System State panel update live.

### What the Streamlit UI is

The Streamlit UI is a **memory visualization dashboard** — it makes the internal state of the memory system visible as a scenario plays. It is not a live chat box. As turns process:

- **Turns Processed** — live counter of turns stored in this session.
- **Context Length** — character count of the memory context. Grows with each turn.
- **Insights** — count of long-term insights. Stays at 0 during the session, jumps at session end.
- **Live Conversation panel** — turn-by-turn dialogue as chat bubbles (blue = User, purple = Advisor).
- **Current Context panel** — expandable; shows the raw memory context the model would receive.
- **Key Insights panel** — structured long-term profile: PREFERENCES, GOALS, BEHAVIOR PATTERNS, KNOWLEDGE LEVEL.

### Steps

1. Open a **third terminal** (click **+**). This is **Terminal 3 — the Streamlit terminal**.

1. Start the Streamlit UI:

   ```
   uv run streamlit run demo/07_interactive_ui.py
   ```

1. When Streamlit prints the URL, open it in the lab VM browser:

   ```
   http://localhost:8501
   ```

1. Confirm the **🟢 Server Online** indicator in the top-right corner. It shows something like `Server Online (2 sessions)`.

   > **If you see 🔴 Server Offline:** Return to Terminal 1 and confirm the server is still running. Restart if needed.

1. Click **💰 Financial Advisor - Session 1 (1)** in the left sidebar.

1. **Before clicking anything**, read the Memory System State panel on the right:

   - **Turns Processed: 0**
   - **Context Length: greater than 0** (e.g., `2,285...`)
   - **Insights: 0**
   - **Key Insights panel: already fully populated** with Sarah's profile

   > **Why is Context Length already non-zero and Key Insights already populated before any turns play?**
   > When you clicked Session 1, the Streamlit UI called `GET http://localhost:8000/memory/context` for `user_id = client_sarah`. The server retrieved Sarah's profile from all prior sessions and injected it into the context before any turn started. The agent already knows Sarah — her income, investment preferences, saving discipline — without her repeating a word. This is exactly the cross-session loading you studied in previous exercises, now made visible.

   > **Why do Shopping Assistant, Learning Assistant, and Medical Assistant scenarios appear empty?**
   > Each scenario uses a different `user_id`. Those scenarios have never been run in this lab environment so the server has no data for those user IDs. Their buttons exist and work correctly — they just have empty Key Insights because there are no prior sessions to load from.

1. Read through the Key Insights panel. Confirm these sections are present: PREFERENCES, GOALS, BEHAVIOR PATTERNS, KNOWLEDGE LEVEL, CROSS-CATEGORY PATTERNS. This is the profile the reflection engine built from all of Sarah's prior sessions.

1. At the bottom of the left sidebar, find **Playback Controls**. Use these options:

   - **⏭ Next (1)** — advances one turn at a time. Use this to read each turn carefully.
   - **▶ Play (2)** — runs all turns automatically at a set pace.

   > **Important — do NOT click ⏸ Pause.** A known issue means clicking Pause can interrupt the async playback loop and stop the Streamlit app. If the app stops, restart it in Terminal 3: `uv run streamlit run demo/07_interactive_ui.py`

1. Click **⏭ Next** three times, checking the Memory System State panel after each click:

   - **After Next 1:** First user turn appears in Live Conversation: *"What is a Roth IRA?"* — **Turns Processed = 1**, Context Length slightly increased.
   - **After Next 2:** Advisor response appears. **Turns Processed = 2**, Context Length increased again.
   - **After Next 3:** Second user turn. **Turns Processed = 3**, Context Length ≈ `2,285...`

1. Click **▶ Play** to run the remaining turns. Watch **Turns Processed** count to 5 and **Context Length** grow.

1. When playback completes, watch the **Insights counter** jump from 0 to a positive number (3–5). This is `end_session(trigger_reflection=True)` running — durable facts extracted, written to the database.

## Task 4: Verify Cross-Session Recall — Session 2 Loading Session 1's Memory

In this task, you will prove that memory persists across separate sessions by watching Session 2 already know everything Session 1 learned — before a single new turn is processed.

### Steps

1. Click **💰 Financial Advisor - Session 2 (1)** in the left sidebar.

1. **Before clicking Play**, confirm in the Memory System State panel:

   - **Turns Processed: 0** — Session 2 has not started. Zero turns added.
   - **Context Length: greater than 0** — already populated despite zero turns.
   - **Key Insights panel** — shows Sarah's full profile, same as at Session 1 end.

   > **This is cross-session recall.** Turns Processed is 0. Yet the context is not empty. The server retrieved Sarah's prior session summaries and long-term insights at session start — before any new turn was processed.

1. Click **▶ Play** and watch the Session 2 conversation. The first user message should reference prior context:

   ```
   User: Based on what we discussed before, what should I prioritise next?
   ```

   The advisor's response should reference Sarah's prior preferences (conservative approach, 60/40 allocation, $500/month contributions) without her having re-stated them.

1. After Session 2 finishes, compare the **Insights counter** to the count from Session 1 — it should be higher, as new insights accumulated or existing ones were updated.

1. Scroll down in the Key Insights panel to **Recent Session Summaries**. Confirm at least two entries with timestamps — one from Session 1, one from Session 2:

   ```
   Recent Session Summaries
   2026-07-24T09:30:00: Session completed.
   Conversation Summary: User asked about next steps given conservative...

   2026-07-24T09:29:00: Session completed.
   Conversation Summary: User asked about Roth IRA basics and limits...
   ```

   > Every future session will load these summaries in its context — giving the agent a compressed relationship history, not just the most recent turns.


## Task 5: Interactive — Type Your Own Prompts and Verify Them in the Browser

This is the exercise's hands-on capstone. You will run the terminal client in **interactive mode**, type your own messages as a new user, end the session, and then verify in the Streamlit browser that those exact messages were stored by the server. This closes the full loop: your input → server → database → browser.

### What you are proving

```
Your terminal prompts
        ↓
POST /turns/store  (HTTP to server)
        ↓
Server stores in database
        ↓
GET /memory/context  (Streamlit calls server)
        ↓
Your data appears in the browser
```

Neither client knows about the other. They share data only because both talk to the same server.

### Before you start — what to expect from interactive mode

Interactive mode opens a real chat loop where you type freely. The agent persona is a financial advisor, so it responds as one — it may ask follow-up questions. **You do not need to answer every question.** Follow the four scripted prompts below. They are designed to create specific, memorable facts (name, income, investment stance, monthly amount) that are easy to spot later in the browser.

> **Expected response length:** The advisor may give a detailed multi-paragraph response, especially to the first prompt. That is normal — just type the next prompt from the list.

### Steps

1. In Terminal 2, start the interactive client:

   ```
   uv run python demo/05_server_mode.py
   ```

1. Wait for the chat prompt. The output will look like:

   ```
   ======================================================================
   💰 Financial Advisor Demo (Remote Memory Service)
   ======================================================================
   Memory Service: http://localhost:8000
   User ID: demo-user-143022

   ✓ Memory service: healthy (3 active sessions)
   ✓ Session started: f9a2c3d4...

   Chat with your financial advisor (type /quit to end)
   ────────────────────────────────────────────────────
   You:
   ```

   > **Write down your `User ID`** — for example `demo-user-143022`. You will use this in Step 7 to verify your data in the server. It changes every run because it is generated from the current time.

1. Type and send the following four prompts **one at a time**. Press Enter after each, wait for the advisor to respond, then type the next:

   **Prompt 1:**
   ```
   My name is Alex and I am a 28-year-old software engineer earning 90000 dollars a year.
   ```
   *Wait for the advisor's response — it may ask follow-up questions. Ignore them and type Prompt 2.*

   **Prompt 2:**
   ```
   I want to invest aggressively. I am comfortable with 100 percent stocks and high volatility.
   ```
   *Wait for the response, then type Prompt 3.*

   **Prompt 3:**
   ```
   I have no debt and I can invest 800 dollars every month.
   ```
   *Wait for the response, then type Prompt 4.*

   **Prompt 4:**
   ```
   Based on what you know about me, what is the single most important first step I should take?
   ```
   *Read the advisor's response — it should reference Alex's age, aggressive stance, and $800/month.*

1. After the advisor responds to Prompt 4, end the session:

   ```
   /quit
   ```

1. Read the session end output:

   ```
   Processing session (extracting insights)...

   ======================================================================
   Session Summary
   ======================================================================
   Turns: 4
   Insights extracted: 3
   Long-term synthesis: Yes
   Summary: Alex is a 28-year-old software engineer with an aggressive
   investment approach, comfortable with 100% stocks. Has $800/month
   available to invest with no debt...
   ======================================================================
   ```

   Confirm the summary accurately reflects your four prompts — Alex's name, aggressive stance, $800/month, no debt. This is the compressed version of your session that future sessions will load.

   > **If the session end times out or crashes:** Your 4 turns were stored before the timeout. The summary may not print, but your data is in the database. Continue to Step 6.

1. Now open (or switch to) the browser at `http://localhost:8501`. The Streamlit sidebar shows only the pre-built scenario buttons — you will not see a button for "Alex" or your `demo-user-143022` ID, because the sidebar buttons are hardcoded to specific scenario user IDs (`client_sarah`, etc.). You will verify your data a different way.

1. To directly query your session from the server, run this in Terminal 2 — replacing `demo-user-143022` with the actual User ID you wrote down in Step 2:

   ```
   Invoke-RestMethod "http://127.0.0.1:8000/health"
   ```

   Then try querying your user's context:

   ```
   Invoke-RestMethod -Uri "http://127.0.0.1:8000/memory/context" -Method GET -Body (@{user_id="demo-user-143022"} | ConvertTo-Json) -ContentType "application/json"
   ```

   > **Note:** The exact endpoint path depends on the server implementation. Check `server/main.py` for the correct route. Look for routes containing `context`, `insights`, or `users`. If the route format is different, adjust the command to match.

1. **Alternative verification — reuse your User ID in the scripted demo.** Open `demo/05_server_mode.py` in VS Code. Find this line near the top:

   ```python
   USER_ID = f"demo-user-{datetime.now().strftime('%H%M%S')}"
   ```

   Temporarily change it to your specific ID from Step 2:

   ```python
   USER_ID = "demo-user-143022"   # replace with your actual ID
   ```

   Save the file and run the scripted demo:

   ```
   uv run python demo/05_server_mode.py --scripted
   ```

   At session start, watch this line closely:

   ```
   ✓ Session started: ...
   ✓ Loaded memory context (850 chars)
   ```

   Compare this context length to Task 5.2 (which started with a fresh user and showed a small or zero context at start). The larger number here is Alex's data — your 4 prompts, the session summary, and extracted insights — all loaded automatically from the database at session start.

   After verifying, restore the original `USER_ID` line:

   ```python
   USER_ID = f"demo-user-{datetime.now().strftime('%H%M%S')}"
   ```

1. Switch back to the browser. Click **💰 Financial Advisor - Session 1** in the sidebar. Scroll down in the Key Insights panel to **Recent Session Summaries**. You should now see additional entries at the top of the list — timestamped from this exercise — alongside the existing Sarah sessions. These are your interactive sessions appearing in the same server's data.

   > **Note:** If you do not see your sessions here, it is because the Streamlit UI's Financial Advisor scenario queries `user_id = client_sarah` specifically — not your `demo-user-143022` ID. Your data exists in the server and was confirmed by the context-length test in Step 8. The Streamlit dashboard shows Sarah's data because that is the user ID the scenario buttons are hardcoded to use.

1. Confirm the final architectural truth of this exercise by reading the following and verifying each point against what you observed:

   | What you did | What it proves |
   |---|---|
   | Typed prompts in terminal → saw `→ Stored (turn N)` | The terminal client sent HTTP to the server; no direct DB access |
   | `/quit` triggered insight extraction | `end_session()` runs on the server, not in the client |
   | Scripted demo started with larger context length after using your User ID | Your data survived as a separate client process started and connected |
   | Streamlit showed 🟢 Server Online throughout | Both clients share one server; neither has its own memory |

   **One server. Multiple clients. Shared memory. This is the architecture.**

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Scroll down in the lab guide and hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
> - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help you out.

---

## 🧾 Summary

In this exercise, you accomplished the following:

- **Started the FastAPI memory server** (`uv run uvicorn server.main:app --host 127.0.0.1 --port 8000`) and verified `/health` returned `healthy` with `active_sessions: 0` before any client connected — Task 5.1.

- **Ran the scripted demo** (`05_server_mode.py --scripted`) and observed session start → 5 turns stored → session end → 3 insights extracted. Confirmed every operation was an HTTP request in the server log. Understood the known ReadTimeout on the search step does not affect stored data — Task 5.2.

- **Launched the Streamlit UI** at `localhost:8501`, confirmed 🟢 Server Online, used **⏭ Next** to advance Financial Advisor Session 1 turn by turn while watching Turns Processed (0→5), Context Length grow, and the Insights counter jump at session end. Understood why Context Length was non-zero before playback (prior session data loaded from database at start) and why other scenarios appear empty (different `user_id`, no data) — Task 5.3.

- **Verified cross-session recall** by clicking Session 2 and confirming Context Length > 0 and the full Key Insights profile were already loaded before Session 2's first turn played. Confirmed the Insights counter grew and Recent Session Summaries listed both sessions — Task 5.4.

- **Ran interactive mode** (`05_server_mode.py` without `--scripted`), typed 4 prompts as Alex (28-year-old engineer, aggressive stance, $800/month, no debt), ended with `/quit`, and verified the session summary confirmed 4 turns stored and insights extracted. Confirmed Alex's data was loaded by the scripted demo when temporarily set to the same User ID — proving data persisted in the server's database and was accessible to a separate client process — Task 5.5.

You have successfully completed this exercise. Click **Next >>** to continue to the next exercise.
